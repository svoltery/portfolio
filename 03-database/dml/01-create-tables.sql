-- PostgreSQL: DDL for notification service

CREATE TYPE device_platform AS ENUM ('ios', 'android', 'huawei');
CREATE TYPE notification_channel AS ENUM ('push', 'sms');
CREATE TYPE notification_category AS ENUM ('сервисное', 'платежное', 'маркетинговое');
CREATE TYPE outbox_status AS ENUM ('new', 'published');
CREATE TYPE delivery_status AS ENUM ('delivered', 'failed');

CREATE TABLE "user" (
    user_id VARCHAR PRIMARY KEY,
    phone VARCHAR NOT NULL,
    email VARCHAR,
    timezone VARCHAR NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_dt TIMESTAMP
);

CREATE TABLE user_device (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    push_token VARCHAR NOT NULL,
    platform device_platform NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_dt TIMESTAMP NOT NULL,
    CONSTRAINT fk_user_device_user FOREIGN KEY (user_id) REFERENCES "user"(user_id)
);

CREATE TABLE service (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR NOT NULL,
    description VARCHAR
);

CREATE TABLE user_service (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    service_id INTEGER NOT NULL,
    is_allowed BOOLEAN NOT NULL,
    updated_dt TIMESTAMP NOT NULL,
    CONSTRAINT fk_user_service_user FOREIGN KEY (user_id) REFERENCES "user"(user_id),
    CONSTRAINT fk_user_service_service FOREIGN KEY (service_id) REFERENCES service(id),
    CONSTRAINT uq_user_service UNIQUE (user_id, service_id)
);

CREATE TABLE category (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category notification_category NOT NULL UNIQUE,
    requires_consent BOOLEAN NOT NULL,
    quiet_hours BOOLEAN NOT NULL,
    priority INTEGER NOT NULL
);

CREATE TABLE notification_template (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    template_id VARCHAR NOT NULL UNIQUE,
    category_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    name VARCHAR NOT NULL,
    created_by VARCHAR NOT NULL,
    updated_by VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    CONSTRAINT fk_template_category FOREIGN KEY (category_id) REFERENCES category(id),
    CONSTRAINT fk_template_service FOREIGN KEY (service_id) REFERENCES service(id)
);

CREATE TABLE notification_template_text (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    notification_template_id INTEGER NOT NULL,
    channel notification_channel NOT NULL,
    channel_priority INTEGER NOT NULL,
    title VARCHAR,
    notification_text TEXT NOT NULL,
    CONSTRAINT fk_template_text_template FOREIGN KEY (notification_template_id) REFERENCES notification_template(id)
);

CREATE TABLE outbox (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    template_text_id INTEGER NOT NULL,
    kafka_message_id VARCHAR,
    status outbox_status NOT NULL DEFAULT 'new',
    message VARCHAR NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    published_dt TIMESTAMP,
    CONSTRAINT fk_outbox_user FOREIGN KEY (user_id) REFERENCES "user"(user_id),
    CONSTRAINT fk_outbox_template_text FOREIGN KEY (template_text_id) REFERENCES notification_template_text(id)
);

CREATE TABLE delivery_attempt (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    outbox_id INTEGER NOT NULL,
    is_fallback BOOLEAN NOT NULL DEFAULT FALSE,
    status delivery_status NOT NULL,
    attempt_number INTEGER NOT NULL,
    created_dt TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_delivery_attempt_outbox FOREIGN KEY (outbox_id) REFERENCES outbox(id)
);
