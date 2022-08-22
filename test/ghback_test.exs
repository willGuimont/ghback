defmodule GhbackTest do
  use ExUnit.Case
  doctest Ghback

  test "greets the world" do
    assert Ghback.hello() == :world
  end
end
