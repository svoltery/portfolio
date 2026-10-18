# 3.1.2. Получение истории уведомлений конкретного клиента

**Назначение:** Получение истории отправленных уведомлений конкретного клиента с возможностью фильтрации и постраничного просмотра.

**Метод и URL:** `GET /api/v1/notifications/{user_id}`

**Фильтрация:** Запрос предусматривает фильтрацию по следующим данным:

1. Дата (одна конкретная дата)
2. Период (дата с — дата по)
3. Тип уведомления (`security`, `antifraud`, `billing`, `system`, `transaction`, `marketing`)
4. Канал доставки (`push` или `sms`)
5. Статус уведомления (`delivered`, `undelivered`, `fail`, `sent`)

## Параметры запроса

| Параметр | Обязательность | Описание |
|---|---|---|
| `page` | — | Номер страницы, по умолчанию = 1 |
| `date` | — | Конкретная дата |
| `date_from` | — | Начало периода |
| `date_to` | — | Конец периода |
| `status` | — | Статус уведомления |
| `channel` | — | Канал доставки уведомления |
| `notification_type` | — | Тип уведомления |

**Пример метода с применением фильтрации:**

```http
GET /api/v1/notifications/123456?date_from=2026-09-01&date_to=2026-09-25&status=delivered&channel=push&page=1&limit=15
```

**Headers:** headers TBD

## Тело ответа: 200 OK

```json
{
  "client": {
    "name": "Иван",
    "last_name": "Иванов"
  },
  "general_info": {
    "total_notifications": 32,
    "delivered": 30,
    "undelivered": 2,
    "delivered_push": 17,
    "delivered_sms": 13
  },
  "notifications": [
    {
      "notification_id": 123456,
      "template_id": "NEW_DEVICE_LOGIN",
      "notification_name": "Вход с нового устройства",
      "notification_type": "Security",
      "notification_status": "delivered",
      "delivered_at": "2026-09-25T07:28:31+03:00",
      "notification_text": "В ваш аккаунт был совершен вход с нового устройства в 07:28. Если входили не вы, обратитесь в службу поддержки банка.",
      "notification_channel": "sms"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 15,
    "total_count": 32,
    "total_pages": 3
  }
}
```

## Ошибки

1. `400` — `{ "message": "Некорректное значение параметра limit." }`
2. `401/403` — TBD
3. `404` — `{ "message": "Запрашиваемый клиент не найден." }`
4. `500` — `{ "message": "Не удалось получить данные. Повторите попытку позже." }`

## Описание блоков ответа

1. `client` — информация о клиенте, историю уведомлений которого запрашивает Web UI.
2. `general_info` — агрегированная информация по уведомлениям, соответствующим текущему запросу и применённым фильтрам. Если фильтры не заданы, статистика рассчитывается по всей доступной истории уведомлений клиента.
3. `pagination` — информация о текущей странице и общем количестве найденных уведомлений.
4. `notifications` — список уведомлений текущей страницы.
5. `delivered_at` заполняется для уведомлений со статусом `delivered`. Для остальных статусов значение отсутствует (`null`).

## Логика запроса

1. Система получает GET-запрос с `user_id` и параметрами запроса.
2. Выполняется аутентификация и авторизация пользователя.
3. Проверяется корректность переданных параметров:
   1. `page` должен быть положительным числом;
   2. `limit` не должен превышать 15;
   3. даты должны соответствовать допустимому формату;
   4. `date_from` не должен быть позже `date_to`;
   5. `status` должен соответствовать поддерживаемому статусу;
   6. `channel` должен соответствовать поддерживаемому каналу.
4. Система проверяет наличие клиента.
5. Из БД выбираются уведомления указанного клиента с учётом переданных фильтров.
6. Рассчитывается общая информация по найденным уведомлениям.
7. Выполняется пагинация результата.
8. Система формирует ответ с информацией о клиенте, общей статистикой, параметрами пагинации и списком уведомлений.
9. Возвращается `200 OK`.

## Маппинг на БД

Маппинг составлен по обновлённой ER-диаграмме, в которой в таблицу `user` добавлены поля `name` и `last_name`. Для `delivered_at` используется согласованное правило: `delivery_attempt.created_dt` — время фиксации успешного результата доставки в нашей системе.

### Поля ответа

| Поле JSON | Таблица БД | Поле БД / правило формирования |
|---|---|---|
| `client.name` | `user` | `name` |
| `client.last_name` | `user` | `last_name` |
| `general_info.total_notifications` | `outbox` | Количество записей `outbox.id` клиента, соответствующих фильтрам |
| `general_info.delivered` | `outbox`, `delivery_attempt` | Количество **уникальных уведомлений** с успешной попыткой (`delivery_attempt.status = 'delivered'`) |
| `general_info.undelivered` | `outbox`, `delivery_attempt` | Количество недоставленных уведомлений; правило определения итогового статуса требует уточнения |
| `general_info.delivered_push` | `delivery_attempt`, `outbox`, `notification_template_text` | Успешные уведомления по каналу `push`; точный учёт фактического канала при fallback требует уточнения |
| `general_info.delivered_sms` | `delivery_attempt`, `outbox`, `notification_template_text` | Успешные уведомления по каналу `sms`; точный учёт фактического канала при fallback требует уточнения |
| `notifications[].notification_id` | `outbox` | `id` |
| `notifications[].template_id` | `notification_template` | `template_id` |
| `notifications[].notification_name` | `notification_template` | `name` |
| `notifications[].notification_type` | `category` | `category`; в БД значения `сервисное / платежное / маркетинговое`, в API — другая классификация |
| `notifications[].notification_status` | `delivery_attempt`, `outbox` | Вычисляется по `delivery_attempt.status` и состоянию отправки; прямого соответствия всем статусам API нет |
| `notifications[].delivered_at` | `delivery_attempt` | `created_dt` успешной попытки, где `status = 'delivered'`; иначе `null` |
| `notifications[].notification_text` | `outbox` | `message` |
| `notifications[].notification_channel` | `notification_template_text` | `channel` связанного текстового варианта; при fallback фактический канал доставки может отличаться |
| `pagination.page` | — | Параметр запроса `page` (по умолчанию 1) |
| `pagination.limit` | — | Параметр запроса `limit` |
| `pagination.total_count` | `outbox` | Количество уведомлений, соответствующих фильтрам, до пагинации |
| `pagination.total_pages` | — | `CEIL(total_count / limit)` |

### Связи таблиц

| Откуда | Куда | Условие связи |
|---|---|---|
| `user` | `outbox` | `user.user_id = outbox.user_id` |
| `outbox` | `delivery_attempt` | `outbox.id = delivery_attempt.outbox_id` |
| `outbox` | `notification_template_text` | `outbox.template_text_id = notification_template_text.id` |
| `notification_template_text` | `notification_template` | `notification_template_text.notification_template_id = notification_template.id` |
| `notification_template` | `category` | `notification_template.category_id = category.id` |

**Примечание:** для расчёта статистики учитываем уведомления (`outbox.id`), а не число попыток доставки, чтобы повторные попытки не завышали счётчики. В текущей ERD у `delivery_attempt` нет отдельного поля канала, поэтому однозначный расчёт статистики по *фактическому* каналу при fallback пока не определён.

## Открытые вопросы

1. Headers.
2. Что должен возвращать метод, если клиент существует, но у него отсутствуют уведомления?
