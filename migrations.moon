
db = require "lapis.db"
schema = require "lapis.db.schema"

import add_column, create_index, drop_index, drop_column, create_table from schema

{
  :serial, :boolean, :varchar, :integer, :text, :foreign_key, :double, :time,
  :numeric, :enum
} = schema.types


{
  =>
    create_table "channel_users", {
      {"id", serial}

      {"channel", varchar}
      {"name", varchar}

      {"messages_count", integer}
      {"last_seen_at", time}

      {"random_message", text}

      {"created_at", time}
      {"updated_at", time}

      "PRIMARY KEY(id)"
    }

    create_index "channel_users", "channel", db.raw("lower(name)"), unique: true

  =>
    create_table "channel_user_point_logs", {
      {"id", serial}
      {"channel_user_id", foreign_key}

      {"reason", text}
      {"amount", integer default: 1}

      {"created_at", time}
      {"updated_at", time}

      "PRIMARY KEY(id)"
    }

    add_column "channel_users", "points_count", integer default: 0

  =>
    create_table "chat_commands", {
      {"id", serial}
      {"command", text}
      {"version", integer}
      {"active", boolean default: true}
      {"type", enum}

      {"data", "json not null"}

      {"used_count", integer default: 0}
      {"last_used_at", time null: true}

      {"created_at", time}
      {"updated_at", time}

      "PRIMARY KEY(id)"
    }

    create_index "chat_commands", "command", "version", unique: true

  =>
    add_column "chat_commands", "secret", boolean default: false

  =>
    create_table "channel_user_messages", {
      {"id", serial}

      {"channel", text}
      {"name", text}

      {"user_id", text null: true}

      {"message", text}

      {"data", "json"}

      {"created_at", time}
      {"updated_at", time}

      "PRIMARY KEY(id)"
    }

    create_index "channel_user_messages", "channel", "created_at"

}
