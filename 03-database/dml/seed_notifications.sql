-- Тестовые данные для системы уведомлений (PostgreSQL)
-- Предполагается, что таблицы уже созданы и пока пусты.
-- Скрипт использует явные ID для удобства проверки связей.
BEGIN;

INSERT INTO "user" (user_id, phone, email, timezone, is_active, created_dt, updated_dt) VALUES
('u001', '+79990000001', 'user01@example.test', 'Europe/Moscow', TRUE, NOW()-INTERVAL '40 days', NULL),
('u002', '+79990000002', 'user02@example.test', 'Europe/Moscow', TRUE, NOW()-INTERVAL '39 days', NULL),
('u003', '+79990000003', 'user03@example.test', 'Asia/Yekaterinburg', TRUE, NOW()-INTERVAL '38 days', NULL),
('u004', '+79990000004', 'user04@example.test', 'Asia/Novosibirsk', TRUE, NOW()-INTERVAL '37 days', NULL),
('u005', '+79990000005', NULL, 'Europe/Kaliningrad', TRUE, NOW()-INTERVAL '36 days', NULL),
('u006', '+79990000006', 'user06@example.test', 'Europe/Moscow', TRUE, NOW()-INTERVAL '35 days', NULL),
('u007', '+79990000007', 'user07@example.test', 'Asia/Vladivostok', TRUE, NOW()-INTERVAL '34 days', NULL),
('u008', '+79990000008', 'user08@example.test', 'Asia/Irkutsk', TRUE, NOW()-INTERVAL '33 days', NULL),
('u009', '+79990000009', NULL, 'Europe/Moscow', FALSE, NOW()-INTERVAL '32 days', NOW()-INTERVAL '2 days'),
('u010', '+79990000010', 'user10@example.test', 'Asia/Krasnoyarsk', TRUE, NOW()-INTERVAL '31 days', NULL),
('u011', '+79990000011', 'user11@example.test', 'Europe/Samara', TRUE, NOW()-INTERVAL '30 days', NULL),
('u012', '+79990000012', 'user12@example.test', 'Asia/Yekaterinburg', TRUE, NOW()-INTERVAL '29 days', NULL);

INSERT INTO service (id, name, description) OVERRIDING SYSTEM VALUE VALUES
(1, 'Travel', 'Подписки и сервис путешествий'),
(2, 'Биллинг', 'Платежи и списания'),
(3, 'Антифрод', 'Операции безопасности'),
(4, 'Карты', 'Уведомления по банковским картам'),
(5, 'Кредиты', 'Платежи по кредитам'),
(6, 'Вклады', 'События по вкладам'),
(7, 'Переводы', 'Денежные переводы'),
(8, 'Маркетинг', 'Предложения и акции'),
(9, 'Лояльность', 'Бонусы и кешбэк'),
(10, 'Профиль', 'Изменения профиля клиента');

INSERT INTO category (id, category, requires_consent, quiet_hours, priority) OVERRIDING SYSTEM VALUE VALUES
(1, 'сервисное', FALSE, TRUE, 2),
(2, 'платежное', FALSE, TRUE, 1),
(3, 'маркетинговое', TRUE, TRUE, 3);

INSERT INTO user_device (id, user_id, push_token, platform, is_active, updated_dt) OVERRIDING SYSTEM VALUE VALUES
(1, 'u001', 'test-token-ios-001', 'ios', TRUE, NOW()),
(2, 'u001', 'test-token-android-002', 'android', TRUE, NOW()),
(3, 'u002', 'test-token-android-003', 'android', TRUE, NOW()),
(4, 'u003', 'test-token-ios-004', 'ios', TRUE, NOW()),
(5, 'u004', 'test-token-android-005', 'android', FALSE, NOW()-INTERVAL '10 days'),
(6, 'u005', 'test-token-ios-006', 'ios', TRUE, NOW()),
(7, 'u006', 'test-token-android-007', 'android', TRUE, NOW()),
(8, 'u007', 'test-token-huawei-008', 'huawei', TRUE, NOW()),
(9, 'u008', 'test-token-ios-009', 'ios', FALSE, NOW()-INTERVAL '3 days'),
(10, 'u009', 'test-token-android-010', 'android', FALSE, NOW()-INTERVAL '2 days'),
(11, 'u010', 'test-token-ios-011', 'ios', TRUE, NOW()),
(12, 'u011', 'test-token-android-012', 'android', TRUE, NOW()),
(13, 'u012', 'test-token-ios-013', 'ios', TRUE, NOW());

INSERT INTO user_service (id, user_id, service_id, is_allowed, updated_dt) OVERRIDING SYSTEM VALUE VALUES
(1, 'u001', 1, TRUE, NOW()),
(2, 'u002', 1, TRUE, NOW()),
(3, 'u003', 1, FALSE, NOW()),
(4, 'u004', 2, TRUE, NOW()),
(5, 'u005', 3, TRUE, NOW()),
(6, 'u006', 4, TRUE, NOW()),
(7, 'u007', 5, FALSE, NOW()),
(8, 'u008', 6, TRUE, NOW()),
(9, 'u009', 7, TRUE, NOW()),
(10, 'u010', 8, FALSE, NOW()),
(11, 'u011', 9, TRUE, NOW()),
(12, 'u012', 10, TRUE, NOW()),
(13, 'u001', 8, TRUE, NOW()),
(14, 'u002', 2, TRUE, NOW()),
(15, 'u006', 1, TRUE, NOW());

INSERT INTO notification_template (id, template_id, category_id, service_id, name, created_by, updated_by, created_at, updated_at) OVERRIDING SYSTEM VALUE VALUES
(1, 'TRAVEL_RENEWAL', 1, 1, 'Напоминание об автопродлении Travel', 'manager01', NULL, NOW()-INTERVAL '30 days', NULL),
(2, 'TRAVEL_ACTIVATED', 1, 1, 'Активация подписки Travel', 'manager01', NULL, NOW()-INTERVAL '29 days', NULL),
(3, 'TRAVEL_CHANGED', 1, 1, 'Изменение тарифа Travel', 'manager01', NULL, NOW()-INTERVAL '28 days', NULL),
(4, 'BILLING_PAID', 2, 2, 'Успешная оплата', 'manager02', NULL, NOW()-INTERVAL '27 days', NULL),
(5, 'BILLING_FAILED', 2, 2, 'Ошибка оплаты', 'manager02', NULL, NOW()-INTERVAL '26 days', NULL),
(6, 'FRAUD_LOGIN', 1, 3, 'Новый вход', 'security01', NULL, NOW()-INTERVAL '25 days', NULL),
(7, 'CARD_ISSUED', 1, 4, 'Выпуск карты', 'manager03', NULL, NOW()-INTERVAL '24 days', NULL),
(8, 'LOAN_DUE', 2, 5, 'Платеж по кредиту', 'manager03', NULL, NOW()-INTERVAL '23 days', NULL),
(9, 'DEPOSIT_INTEREST', 2, 6, 'Начисление процентов', 'manager03', NULL, NOW()-INTERVAL '22 days', NULL),
(10, 'TRANSFER_DONE', 2, 7, 'Перевод выполнен', 'manager04', NULL, NOW()-INTERVAL '21 days', NULL),
(11, 'PROMO_OFFER', 3, 8, 'Специальное предложение', 'marketing01', NULL, NOW()-INTERVAL '20 days', NULL),
(12, 'LOYALTY_BONUS', 1, 9, 'Начисление бонусов', 'manager04', NULL, NOW()-INTERVAL '19 days', NULL);

INSERT INTO notification_template_text (id, notification_template_id, channel, channel_priority, title, notification_text) OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'push', 1, 'Продление Travel', 'Подписка Travel продлится {renewal_date}. Управление в приложении.'),
(2, 1, 'sms', 2, NULL, 'Travel: автопродление {renewal_date}. Настройки в приложении.'),
(3, 2, 'push', 1, 'Travel подключен', 'Ваша подписка Travel активирована.'),
(4, 2, 'sms', 2, NULL, 'Подписка Travel успешно активирована.'),
(5, 3, 'push', 1, 'Тариф изменен', 'Ваш тариф Travel изменен на {tariff}.'),
(6, 4, 'push', 1, 'Оплата прошла', 'Платеж на сумму {amount} выполнен.'),
(7, 5, 'sms', 2, NULL, 'Не удалось выполнить платеж {amount}.'),
(8, 6, 'push', 1, 'Вход в аккаунт', 'Зафиксирован новый вход в аккаунт.'),
(9, 7, 'push', 1, 'Карта готова', 'Ваша новая карта выпущена.'),
(10, 8, 'sms', 2, NULL, 'Напоминание: платеж по кредиту {due_date}.'),
(11, 9, 'push', 1, 'Проценты начислены', 'Начислены проценты по вкладу.'),
(12, 10, 'push', 1, 'Перевод выполнен', 'Ваш перевод успешно выполнен.'),
(13, 11, 'push', 1, 'Предложение для вас', 'В приложении доступно новое предложение.'),
(14, 12, 'push', 1, 'Бонусы начислены', 'Вам начислены бонусы программы лояльности.'),
(15, 3, 'sms', 2, NULL, 'Тариф Travel изменен на {tariff}.'),
(16, 4, 'sms', 2, NULL, 'Платеж {amount} успешно выполнен.'),
(17, 5, 'push', 1, 'Ошибка платежа', 'Не удалось выполнить платеж {amount}.'),
(18, 11, 'sms', 2, NULL, 'В приложении банка доступно новое предложение.');

INSERT INTO outbox (id, user_id, template_text_id, kafka_message_id, status, message, created_dt, published_dt) OVERRIDING SYSTEM VALUE VALUES
(1, 'u001', 1, 'kafka-001', 'published', 'Подписка Travel продлится 20.10.2026. Управление в приложении.', NOW()-INTERVAL '14 hours', NOW()-INTERVAL '13 hours 59 minutes'),
(2, 'u002', 1, 'kafka-002', 'published', 'Подписка Travel продлится 21.10.2026. Управление в приложении.', NOW()-INTERVAL '13 hours', NOW()-INTERVAL '12 hours 59 minutes'),
(3, 'u003', 2, 'kafka-003', 'published', 'Travel: автопродление 22.10.2026. Настройки в приложении.', NOW()-INTERVAL '12 hours', NOW()-INTERVAL '11 hours 59 minutes'),
(4, 'u004', 6, 'kafka-004', 'published', 'Платеж на сумму 1200 руб. выполнен.', NOW()-INTERVAL '11 hours', NOW()-INTERVAL '10 hours 59 minutes'),
(5, 'u005', 8, 'kafka-005', 'published', 'Зафиксирован новый вход в аккаунт.', NOW()-INTERVAL '10 hours', NOW()-INTERVAL '9 hours 59 minutes'),
(6, 'u006', 9, 'kafka-006', 'published', 'Ваша новая карта выпущена.', NOW()-INTERVAL '9 hours', NOW()-INTERVAL '8 hours 59 minutes'),
(7, 'u007', 10, 'kafka-007', 'published', 'Напоминание: платеж по кредиту 25.10.2026.', NOW()-INTERVAL '8 hours', NOW()-INTERVAL '7 hours 59 minutes'),
(8, 'u008', 11, 'kafka-008', 'published', 'Начислены проценты по вкладу.', NOW()-INTERVAL '7 hours', NOW()-INTERVAL '6 hours 59 minutes'),
(9, 'u009', 12, 'kafka-009', 'published', 'Ваш перевод успешно выполнен.', NOW()-INTERVAL '6 hours', NOW()-INTERVAL '5 hours 59 minutes'),
(10, 'u010', 13, 'kafka-010', 'published', 'В приложении доступно новое предложение.', NOW()-INTERVAL '5 hours', NOW()-INTERVAL '4 hours 59 minutes'),
(11, 'u011', 14, 'kafka-011', 'published', 'Вам начислены бонусы программы лояльности.', NOW()-INTERVAL '4 hours', NOW()-INTERVAL '3 hours 59 minutes'),
(12, 'u012', 3, 'kafka-012', 'published', 'Ваша подписка Travel активирована.', NOW()-INTERVAL '3 hours', NOW()-INTERVAL '2 hours 59 minutes'),
(13, 'u001', 2, 'kafka-013', 'published', 'Travel: автопродление 20.10.2026. Настройки в приложении.', NOW()-INTERVAL '2 hours', NOW()-INTERVAL '1 hour 59 minutes'),
(14, 'u002', 17, 'kafka-014', 'published', 'Не удалось выполнить платеж 500 руб.', NOW()-INTERVAL '90 minutes', NOW()-INTERVAL '89 minutes'),
(15, 'u006', 5, NULL, 'new', 'Ваш тариф Travel изменен на Семейный.', NOW()-INTERVAL '20 minutes', NULL),
(16, 'u001', 13, NULL, 'new', 'В приложении доступно новое предложение.', NOW()-INTERVAL '10 minutes', NULL);

INSERT INTO delivery_attempt (id, outbox_id, is_fallback, status, attempt_number, created_dt) OVERRIDING SYSTEM VALUE VALUES
(1, 1, FALSE, 'delivered', 1, NOW()-INTERVAL '13 hours 58 minutes'),
(2, 2, FALSE, 'failed', 1, NOW()-INTERVAL '12 hours 58 minutes'),
(3, 2, TRUE, 'delivered', 2, NOW()-INTERVAL '12 hours 57 minutes'),
(4, 3, FALSE, 'delivered', 1, NOW()-INTERVAL '11 hours 58 minutes'),
(5, 4, FALSE, 'delivered', 1, NOW()-INTERVAL '10 hours 58 minutes'),
(6, 5, FALSE, 'failed', 1, NOW()-INTERVAL '9 hours 58 minutes'),
(7, 5, TRUE, 'failed', 2, NOW()-INTERVAL '9 hours 57 minutes'),
(8, 6, FALSE, 'delivered', 1, NOW()-INTERVAL '8 hours 58 minutes'),
(9, 7, FALSE, 'delivered', 1, NOW()-INTERVAL '7 hours 58 minutes'),
(10, 8, FALSE, 'delivered', 1, NOW()-INTERVAL '6 hours 58 minutes'),
(11, 9, FALSE, 'failed', 1, NOW()-INTERVAL '5 hours 58 minutes'),
(12, 10, FALSE, 'delivered', 1, NOW()-INTERVAL '4 hours 58 minutes'),
(13, 11, FALSE, 'delivered', 1, NOW()-INTERVAL '3 hours 58 minutes'),
(14, 12, FALSE, 'delivered', 1, NOW()-INTERVAL '2 hours 58 minutes'),
(15, 13, FALSE, 'delivered', 1, NOW()-INTERVAL '1 hour 58 minutes'),
(16, 14, FALSE, 'failed', 1, NOW()-INTERVAL '88 minutes');

-- Синхронизация последовательностей IDENTITY после вставки явных ID.
SELECT setval(pg_get_serial_sequence('user_device', 'id'), (SELECT MAX(id) FROM user_device));
SELECT setval(pg_get_serial_sequence('service', 'id'), (SELECT MAX(id) FROM service));
SELECT setval(pg_get_serial_sequence('user_service', 'id'), (SELECT MAX(id) FROM user_service));
SELECT setval(pg_get_serial_sequence('category', 'id'), (SELECT MAX(id) FROM category));
SELECT setval(pg_get_serial_sequence('notification_template', 'id'), (SELECT MAX(id) FROM notification_template));
SELECT setval(pg_get_serial_sequence('notification_template_text', 'id'), (SELECT MAX(id) FROM notification_template_text));
SELECT setval(pg_get_serial_sequence('outbox', 'id'), (SELECT MAX(id) FROM outbox));
SELECT setval(pg_get_serial_sequence('delivery_attempt', 'id'), (SELECT MAX(id) FROM delivery_attempt));

COMMIT;

-- Проверка количества записей.
SELECT 'user' AS table_name, COUNT(*) AS rows_count FROM "user"
UNION ALL SELECT 'user_device', COUNT(*) FROM user_device
UNION ALL SELECT 'service', COUNT(*) FROM service
UNION ALL SELECT 'user_service', COUNT(*) FROM user_service
UNION ALL SELECT 'category', COUNT(*) FROM category
UNION ALL SELECT 'notification_template', COUNT(*) FROM notification_template
UNION ALL SELECT 'notification_template_text', COUNT(*) FROM notification_template_text
UNION ALL SELECT 'outbox', COUNT(*) FROM outbox
UNION ALL SELECT 'delivery_attempt', COUNT(*) FROM delivery_attempt
ORDER BY table_name;
