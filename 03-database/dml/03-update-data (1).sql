-- PostgreSQL
-- Примеры UPDATE для бизнес-сценариев системы уведомлений.
-- Запросы независимы. Проверьте существование записей перед выполнением.

-- 1. Деактивация устройства пользователя.
UPDATE user_device
SET
    is_active = FALSE,
    updated_dt = NOW()
WHERE id = 3
  AND is_active = TRUE;

-- 2. Запрет уведомлений от конкретного сервиса.
UPDATE user_service
SET
    is_allowed = FALSE,
    updated_dt = NOW()
WHERE user_id = 'u001'
  AND service_id = 1;

-- 3. Фиксация успешной публикации сообщения в Kafka.
UPDATE outbox
SET
    status = 'published',
    published_dt = NOW(),
    kafka_message_id = 'kafka-015'
WHERE id = 15
  AND status = 'new';

-- 4. Повышение приоритета платежных уведомлений.
-- Предполагается: меньшее число означает более высокий приоритет.
UPDATE category
SET priority = 0
WHERE category = 'платежное';
