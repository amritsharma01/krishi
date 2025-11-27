## Notifications API Contract

This document captures what the Flutter client currently expects from the
notification-related endpoints so the backend implementation can line up with the
app behaviour.

### Base Conventions

- **Base URL**: `GET.baseUrl` (currently `http://192.168.1.65:8000/`) is
  prepended to every path listed below.
- **Authentication**: All endpoints listed here require an `Authorization`
  header in the format `Token <access_token>`.
- **Pagination**: List endpoints expect Django-style pagination objects:
  - `count`: total items matching the filter
  - `next`: absolute or relative URL to the next page (nullable)
  - `previous`: absolute or relative URL to the previous page (nullable)
  - `results`: array of `AppNotification` objects (schema below)
- **Dates**: ISO-8601 strings, e.g. `"2024-11-27T09:41:12.123Z"`.

### Notification Resource Schema (`AppNotification`)

```jsonc
{
  "id": 42,
  "notification_type": "order_update",          // machine-readable type
  "notification_type_display": "Order Update",   // human label
  "title": "Order #1234 is on the way",
  "message": "Rider left the warehouse at 14:32.",
  "related_order_id": 1234,                      // nullable ints
  "related_product_id": null,
  "related_review_id": null,
  "related_comment_id": null,
  "is_read": false,
  "read_at": null,                               // null until read
  "created_at": "2024-11-27T09:41:12.123Z"
}
```

The client gracefully accepts `null`, numeric strings, or ints for the related
IDs and parses `read_at`/`created_at` using `DateTime.tryParse`.

### Endpoint Summary

| Purpose | Method & Path | Request Body | Response |
| --- | --- | --- | --- |
| List all notifications | `GET /notifications/?page=<n>` | — | Paginated notifications |
| List unread notifications | `GET /notifications/unread/?page=<n>` | — | Paginated notifications filtered to `is_read=false` |
| Fetch single notification | `GET /notifications/{id}/` | — | One `AppNotification` |
| Fetch unread count | `GET /notifications/unread_count/` | — | Count object (see below) |
| Mark one notification as read | `POST /notifications/{id}/mark_as_read/` | `{ "is_read": true }` | Updated `AppNotification` |
| Mark all as read | `POST /notifications/mark_all_as_read/` | `{ "is_read": true }` | 200/204 empty body |
| Delete one notification | `DELETE /notifications/{id}/delete_notification/` | — | 204 empty |
| Delete all read notifications | `DELETE /notifications/delete_all_read/` | — | 204 empty |

Details for each endpoint follow.

---

#### 1. GET `/notifications/`

- **Query params**:
  - `page` *(int, default 1)* — the UI passes this when the user scrolls.
- **Response**: paginated payload described above.
  ```jsonc
  {
    "count": 120,
    "next": "/notifications/?page=3",
    "previous": "/notifications/?page=1",
    "results": [ { ...AppNotification }, ... ]
  }
  ```

#### 2. GET `/notifications/unread/`

Identical contract to the list endpoint, but should only return unread items.
The UI toggles to this path when it wants unseen notifications.

#### 3. GET `/notifications/{id}/`

Returns a single `AppNotification`. Used when refreshing a card after a backend
operation.

#### 4. GET `/notifications/unread_count/`

- **Response**: the client accepts multiple shapes for resilience:
  ```jsonc
  { "count": 5 }
  ```
  or
  ```jsonc
  { "unread_count": 5 }
  ```
  or
  ```jsonc
  { "results": [ {}, {}, {}, {}, {} ] }
  ```
  or simply:
  ```json
  5
  ```
  Returning `{ "count": <int> }` is preferred.

The unread badge uses this endpoint to update a Riverpod state notifier.

#### 5. POST `/notifications/{id}/mark_as_read/`

- **Request body**: `{ "is_read": true }`
- **Response**: full `AppNotification` after being marked read (with updated
  `is_read=true` and `read_at` timestamp). The UI uses the returned payload to
  update local state.

Marking a notification as read should also cause the unread-count endpoint to
reflect the decremented value.

#### 6. POST `/notifications/mark_all_as_read/`

- **Request body**: `{ "is_read": true }`
- **Response**: empty 200/204 or `{ "success": true }`.

After this call the UI locally sets every notification to read and resets the
unread-count provider to zero, so backend just needs to ensure all stored
records are updated.

#### 7. DELETE `/notifications/{id}/delete_notification/`

Deletes a single notification. UI expects:

- 204/200 success status with empty body (optional `{ "detail": "deleted" }`).
- 404 if already gone (handled gracefully).

#### 8. DELETE `/notifications/delete_all_read/`

Removes every notification where `is_read=true`. On success the UI clears its
local list of read items and shows a success toast.

### Client Workflow Notes

- **Badge updates**: `lib/features/components/notification_icon.dart` reads
  `unreadNotificationsProvider`. Backend must keep `/unread_count/` fast because
  it refreshes whenever a notification is opened or marked read.
- **Optimistic actions**: The UI optimistically updates lists on swipe-to-delete
  or mark-as-read, but it will re-fetch on failure. Returning the updated object
  reduces drift.
- **SSE/push**: Not implemented yet; the client relies entirely on polling via
  the APIs above.

### Error Handling Expectations

- Standard JSON error with `detail` or `errors` fields.
- 401 should be returned if `Authorization` header is missing/invalid; the app
  automatically clears tokens when it receives 401.
- 400+ responses should include meaningful error text because the UI surfaces
  the translated generic strings (`failed_to_load_notifications`, etc.) along
  with any server-provided detail when available.

### Future Enhancements (optional for backend)

- Support for filtering by `notification_type`.
- Support server-driven page size (`page_size` query param).
- Bulk action endpoints (e.g., mark selected IDs as read) if needed later.

With the above contract implemented, the current Flutter notification UI will
work without further code changes.

