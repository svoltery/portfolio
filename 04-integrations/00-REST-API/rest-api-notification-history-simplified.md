# 3.1.2. Получение истории уведомлений конкретного клиента

**Назначение:** Получение списка уведомлений конкретного клиента с фильтрацией и постраничным просмотром.

**Метод и URL:** `GET /api/v1/notifications/{user_id}`

## Параметры запроса

| Параметр | Обязательность | Описание |
|---|---|---|
| `user_id` (path) | Да | Идентификатор клиента |
| `page` | Нет | Номер страницы, по умолчанию `1` |
| `limit` | Нет | Количество уведомлений на странице, по умолчанию `15`, максимум `15` |
| `date` | Нет | Конкретная дата создания уведомления, формат `YYYY-MM-DD` |
| `date_from` | Нет | Начало периода создания уведомлений, формат `YYYY-MM-DD` |
| `date_to` | Нет | Конец периода создания уведомлений, формат `YYYY-MM-DD` |
| `status` | Нет | Итоговый статус последней попытки: `delivered` или `failed` |
| `channel` | Нет | Канал текстового варианта уведомления: `push` или `sms` |
| `notification_type` | Нет | Категория уведомления: `сервисное`, `платежное`, `маркетинговое` |

**Правило фильтрации по датам:** `date` используется отдельно от `date_from` и `date_to`; при одновременной передаче возвращается `400`. Границы периода включаются.

**Пример запроса:**

```http
GET /api/v1/notifications/123456?date_from=2026-09-01&date_to=2026-09-25&status=delivered&page=1&limit=15 HTTP/1.1
Authorization: Bearer <access_token>
Accept: application/json
```

## Заголовки запроса

| Заголовок | Обязательность | Описание |
|---|---|---|
| `Authorization` | Да | `Bearer <access_token>` — JWT авторизованного сотрудника WebUI |
| `Accept` | Нет | `application/json` |

`Content-Type` для GET без тела запроса не требуется. Предполагается, что JWT проверяется в рамках принятой схемы авторизации внутреннего WebUI; сотруднику необходимо право на просмотр истории уведомлений.

## Тело ответа: 200 OK

```json
{
  "client": {
    "name": "Иван",
    "last_name": "Иванов"
  },
  "notifications": [
    {
      "notification_id": 123456,
      "template_id": "NEW_DEVICE_LOGIN",
      "notification_name": "Вход с нового устройства",
      "notification_type": "сервисное",
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

## Описание блоков ответа

1. `client` — имя и фамилия клиента.
2. `notifications` — список уведомлений на текущей странице. Каждое уведомление (`outbox.id`) отображается **один раз**.
3. `pagination` — номер страницы, размер страницы, общее число найденных уведомлений и число страниц.
4. `notification_status` — статус **последней попытки доставки** по максимальному `attempt_number`. Если попыток ещё нет, возвращается `null`.
5. `delivered_at` — `created_dt` последней попытки, только если её статус `delivered`; иначе `null`.
6. `notification_channel` — канал, указанный в связанном варианте шаблона (`notification_template_text.channel`), **не гарантирует фактический канал при fallback**.

**Если клиент существует, но уведомлений нет:** возвращается `200 OK`, `notifications: []`, `pagination.total_count: 0`, `pagination.total_pages: 0`. Блок `client` сохраняется.

## Коды ошибок

| HTTP-код | Когда возникает | Тело ответа |
|---|---|---|
| `400 Bad Request` | Некорректные параметры фильтрации или пагинации | `{"message": "Некорректные параметры запроса"}` |
| `401 Unauthorized` | Токен отсутствует, недействителен или истёк | `{"message": "Требуется авторизация"}` |
| `403 Forbidden` | У сотрудника нет права просматривать историю уведомлений | `{"message": "Недостаточно прав для просмотра истории уведомлений"}` |
| `404 Not Found` | Клиент с указанным `user_id` не найден | `{"message": "Запрашиваемый клиент не найден."}` |
| `500 Internal Server Error` | Непредвиденная ошибка при получении данных | `{"message": "Не удалось получить данные. Повторите попытку позже."}` |

## Логика обработки запроса

1. Система получает GET-запрос с `user_id` и параметрами фильтрации.
2. Проверяет JWT и право сотрудника на просмотр истории уведомлений. При ошибке возвращает `401` или `403`.
3. Проверяет параметры: `page >= 1`, `1 <= limit <= 15`, формат дат, `date_from <= date_to`, допустимые значения `status`, `channel`, `notification_type`; при ошибке возвращает `400`.
4. Проверяет наличие клиента в `user`; если клиент не найден — `404`.
5. Выбирает записи `outbox` клиента, соединяет с шаблоном и категорией, для каждой записи получает последнюю попытку из `delivery_attempt` (по наибольшему `attempt_number`). Отсутствие попыток не исключает уведомление из истории.
6. Применяет фильтры; сортирует уведомления по `outbox.created_dt` от новых к старым (при совпадении — по `outbox.id` по убыванию).
7. Вычисляет `total_count` до пагинации, выбирает страницу с учётом `page` и `limit`.
8. Формирует `client`, `notifications` и `pagination`, возвращает `200 OK`.

## Маппинг на БД

| Поле ответа | Таблица | Поле / правило |
|---|---|---|
| `client.name` | `user` | `name` |
| `client.last_name` | `user` | `last_name` |
| `notifications[].notification_id` | `outbox` | `id` |
| `notifications[].template_id` | `notification_template` | `template_id` |
| `notifications[].notification_name` | `notification_template` | `name` |
| `notifications[].notification_type` | `category` | `category` |
| `notifications[].notification_status` | `delivery_attempt` | `status` последней попытки (максимальный `attempt_number`), иначе `null` |
| `notifications[].delivered_at` | `delivery_attempt` | `created_dt` последней попытки при `status = 'delivered'`, иначе `null` |
| `notifications[].notification_text` | `outbox` | `message` |
| `notifications[].notification_channel` | `notification_template_text` | `channel` связанного текстового варианта |
| `pagination.page` | — | `page` из запроса или `1` |
| `pagination.limit` | — | `limit` из запроса или `15` |
| `pagination.total_count` | `outbox` | Количество уникальных уведомлений после фильтрации, до пагинации |
| `pagination.total_pages` | — | `CEIL(total_count / limit)` |

### Связи таблиц

| Таблицы | Условие связи |
|---|---|
| `user` → `outbox` | `user.user_id = outbox.user_id` |
| `outbox` → `notification_template_text` | `outbox.template_text_id = notification_template_text.id` |
| `notification_template_text` → `notification_template` | `notification_template_text.notification_template_id = notification_template.id` |
| `notification_template` → `category` | `notification_template.category_id = category.id` |
| `outbox` → `delivery_attempt` | `outbox.id = delivery_attempt.outbox_id`; выбирается только последняя попытка |

## Принятые упрощения

- Удалён блок `general_info` со статистикой доставки.
- Статусы фильтрации сведены к значениям `delivery_attempt`: `delivered` и `failed`. Для уведомлений без попыток `notification_status = null`.
- Типы уведомлений соответствуют справочнику `category` в БД.
- Канал в ответе — канал варианта шаблона, а не подтверждённый фактический канал доставки после fallback.
- `delivered_at` — время фиксации успешного результата в нашей системе, а не гарантированное время появления уведомления на устройстве.
