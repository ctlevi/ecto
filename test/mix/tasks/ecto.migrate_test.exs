defmodule Mix.Tasks.Ecto.MigrateTest do
  use ExUnit.Case, async: true

  import Mix.Tasks.Ecto.Migrate, only: [run: 2, run: 3]

  defmodule Repo do
    def start_link do
      Process.put(:started, true)
      :ok
    end

    def __repo__ do
      true
    end

    def config do
      [priv: "hello", otp_app: :ecto]
    end
  end

  test "runs the migrator without starting" do
    run ["-r", to_string(Repo), "--no-start", "--no-create"], fn _, _, _, _ ->
      Process.put(:migrated, true)
    end
    assert Process.get(:migrated)
    refute Process.get(:started)
  end

  test "runs the migrator yielding the repository and migrations path" do
    run ["-r", to_string(Repo), "--no-create"], fn repo, path, direction, strategy ->
      assert repo == Repo
      assert path == Application.app_dir(:ecto, "hello/migrations")
      assert direction == :up
      assert strategy[:all] == true
    end
    assert Process.get(:started)
  end

  test "runs ecto.create before migrating" do
    run ["-r", to_string(Repo), "--no-start"], fn _, _, _, _ ->
      Process.put(:migrated, true)
    end, fn _ ->
      Process.put(:created, true)
    end
    assert Process.get(:migrated)
    assert Process.get(:created)
  end

  test "runs migrator without creating" do
    run ["-r", to_string(Repo), "--no-start", "--no-create"], fn _, _, _, _ ->
      Process.put(:migrated, true)
    end, fn _ ->
      Process.put(:created, true)
    end
    assert Process.get(:migrated)
    refute Process.get(:created)
  end
end
