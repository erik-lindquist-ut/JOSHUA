defmodule TentativeOne.GateTest do
  use ExUnit.Case, async: true
  alias TentativeOne.Gate

  describe "classify/1 — assume 1" do
    test "plain work is a tentative 1" do
      assert Gate.classify("draft the Santorini section") == :one
      assert Gate.classify("rename the folder to V2") == :one
      assert Gate.classify("") == :one
    end
  end

  describe "classify/1 — the inflection points are the only 0s" do
    test "deleting or overwriting his files" do
      assert {:zero, :destroy} = Gate.classify("delete the old logs")
      assert {:zero, :destroy} = Gate.classify("overwrite MIND.md")
      assert {:zero, :destroy} = Gate.classify("rm -rf 90_Archive")
    end

    test "sending anything out" do
      assert {:zero, :send} = Gate.classify("email the deck to Gordon")
      assert {:zero, :send} = Gate.classify("post it to LinkedIn")
      assert {:zero, :send} = Gate.classify("git push to origin")
      assert {:zero, :send} = Gate.classify("share the artifact")
    end

    test "money" do
      assert {:zero, :money} = Gate.classify("pay the $85 filing fee")
      assert {:zero, :money} = Gate.classify("buy the domain")
    end

    test "regulated or institutional data" do
      assert {:zero, :regulated} = Gate.classify("copy the FERPA roster")
      assert {:zero, :regulated} = Gate.classify("pull the SSN column")
    end

    test "an email address on something outbound" do
      assert {:zero, :address} = Gate.classify("sign it el.3079@gmail.com")
    end

    test "passwords, ever" do
      assert {:zero, :password} = Gate.classify("make a password for Relay")
    end

    test "word boundaries — no false 0s" do
      assert Gate.classify("deleted scenes list, read only") == :one
      assert Gate.classify("the payoff chapter") == :one
      assert Gate.classify("postmortem notes") == :one
      assert Gate.classify("tighten the text of chapter 2") == :one
    end
  end
end
