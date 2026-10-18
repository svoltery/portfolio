# 1. Входящие интеграции 

## 1.1. Создание шаблона с WebUI

**Метод и URL:** `POST /api/v1/templates`  
**Назначение:** создание шаблона уведомления с вариантами текста для каналов Push и SMS.

### Заголовки запроса

| Заголовок | Обязательность | Значение / назначение |
|---|---|---|
| `Authorization` | Да | `Bearer <access_token>` — JWT сотрудника |
| `Content-Type` | Да | `application/json` — формат тела запроса |
| `Accept` | Да | `application/json` — желаемый формат ответа |

**Пример HTTP-запроса:**

```http
POST /api/v1/templates HTTP/1.1
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

### Тело запроса (пример)

```json
{
  "template_id": "MARKETING_HOTEL_DISCOUNT",
  "category_id": 1,
  "service_id": 2,
  "name": "Скидка 25% на бронь отелей",
  "channels": {
    "push": {
      "title": "Забронируйте отель",
      "notification_text": "*client_name*, для вас доступна скидка *discount_percent* при бронировании отелей, подробности в приложении",
      "channel_priority": 1
    },
    "sms": {
      "notification_text": "*client_name*, для вас доступна скидка *discount_percent* при бронировании отелей, ищите подробности по ссылке *link*",
      "channel_priority": 2
    }
  }
}
```

### Успешный ответ — `201 Created`

**Заголовок ответа:** `Content-Type: application/json`

```json
{
  "id": 100,
  "template_id": "MARKETING_HOTEL_DISCOUNT",
  "category_id": 1,
  "service_id": 2,
  "name": "Скидка 25% на бронь отелей",
  "created_by": "employee_12345",
  "created_at": "2026-09-03T14:30:00+03:00",
  "channels": {
    "push": {
      "id": 20,
      "title": "Забронируйте отель",
      "notification_text": "*client_name*, для вас доступна скидка *discount_percent* при бронировании отелей, подробности в приложении",
      "channel_priority": 1
    },
    "sms": {
      "id": 21,
      "notification_text": "*client_name*, для вас доступна скидка *discount_percent* при бронировании отелей, ищите подробности по ссылке *link*",
      "channel_priority": 2
    }
  }
}
```

`created_by` в ответе — идентификатор сотрудника из проверенного токена. Значение `employee_12345` условное.

### Коды ошибок

| HTTP-код | Когда возвращается | Пример тела ответа |
|---|---|---|
| `400 Bad Request` | Некорректный JSON, отсутствует обязательное поле или неверный тип данных | `{"message": "Поле service_id является обязательным"}` |
| `401 Unauthorized` | Токен отсутствует, недействителен или истёк | `{"message": "Требуется авторизация"}` |
| `403 Forbidden` | Сотрудник аутентифицирован, но не имеет права создавать шаблоны | `{"message": "Недостаточно прав для создания шаблона уведомления"}` |
| `409 Conflict` | Шаблон с указанным `template_id` уже существует | `{"message": "Шаблон с таким идентификатором уже существует"}` |
| `500 Internal Server Error` | Непредвиденная внутренняя ошибка | `{"message": "Не удалось создать шаблон уведомления. Повторите попытку позже."}` |

Для ответа `401` сервер также возвращает заголовок `WWW-Authenticate: Bearer`.

### Маппинг на БД

| Поле в JSON / источник | Таблица БД | Поле БД |
|---|---|---|
| `template_id` | `notification_template` | `template_id` |
| `category_id` | `notification_template` | `category_id` |
| `service_id` | `notification_template` | `service_id` |
| `name` | `notification_template` | `name` |
| `created_by` | `notification_template` | `created_by` |
| `channels.push` | `notification_template_text` | `channel = 'push'` |
| `channels.sms` | `notification_template_text` | `channel = 'sms'` |
| `channels.*.title` | `notification_template_text` | `title` |
| `channels.*.notification_text` | `notification_template_text` | `notification_text` |
| `channels.*.channel_priority` | `notification_template_text` | `channel_priority` |

Дополнительно система заполняет `notification_template.created_at`, создаёт связь `notification_template_text.notification_template_id` с новым шаблоном и генерирует технические `id`.

### Последовательность обработки запроса

1. WebUI отправляет `POST /api/v1/templates` с JWT в заголовке `Authorization`.
2. API Gateway проверяет наличие и действительность токена. При неуспешной проверке возвращается `401`.
3. Сервис проверяет право сотрудника `notification_template:create`. Если права нет, возвращается `403`.
4. Система получает идентификатор сотрудника из проверенного контекста аутентификации для записи в `created_by`.
5. Система проверяет корректность JSON и обязательные поля. При ошибке возвращается `400`.
6. В рамках одной транзакции проверяется уникальность `notification_template.template_id`. Если шаблон с таким значением уже существует, возвращается `409`. Уникальность также обеспечивается ограничением `UNIQUE` в БД.
7. Создаётся запись в `notification_template`; в `created_at` фиксируется время создания, в `created_by` — идентификатор сотрудника.
8. В `notification_template_text` создаются две связанные записи — для `push` и `sms`.
9. Транзакция завершается успешно; API возвращает `201 Created` и созданный шаблон.

### Обработка ошибок

| Тип ошибки | Когда возникает | Действие |
|---|---|---|
| Отсутствующий или недействительный токен | Нет JWT, токен просрочен или не прошёл проверку | Не выполнять создание, вернуть `401` |
| Недостаточно прав | Сотрудник аутентифицирован, но не имеет права создавать шаблоны | Не выполнять создание, вернуть `403` |
| Дубликат `template_id` | Шаблон с таким `template_id` уже существует | Не сохранять новый шаблон, вернуть `409` |
| Невалидный запрос / нарушение JSON-контракта | JSON невалиден, отсутствует обязательное поле, неверный тип данных | Не сохранять данные, вернуть `400` |
| Внутренняя ошибка сервиса | Непредвиденная ошибка при обработке запроса | Откатить транзакцию, записать ошибку в журнал, вернуть `500` |

### Открытые вопросы

- Какое фактическое право или роль разрешает создание шаблонов?
- Какой именно идентификатор сотрудника сохраняется в `created_by` (`sub`, корпоративный ID или другой стабильный идентификатор)?


