defmodule TentativeOne.GateCorpusTest do
  @moduledoc "One spec per phrase. Zeros must fire with the right reason; ones must not fire at all."
  use ExUnit.Case, async: true
  alias TentativeOne.Gate

  @zeros %{
    destroy: [
      "delete the old logs", "Delete MIND.pdf", "remove 90_Archive", "overwrite the index",
      "erase the draft", "wipe the scratch folder", "trash the old covers", "rm -rf build",
      "rm -f notes.md", "please delete it", "DELETE everything", "remove the second pin",
      "overwrite V2.7 FOUNDERS", "erase Ouroboros entry 12", "wipe and rebuild", "trash it",
      "delete then rebuild the PDFs", "remove duplicates from the folder", "overwrite with v3",
      "can you delete the tmp files", "delete: yes", "remove it for good", "erase the board",
      "wipe the cache", "rm -r old"
    ],
    send: [
      "email the deck to Gordon", "send it to Kristin", "post it to LinkedIn", "publish the page",
      "share the artifact", "git push to origin", "submit the filing", "tweet the launch",
      "Send the brief", "EMAIL the team", "e-mail the summary", "post the update in Slack",
      "publish to KDP", "share with my manager", "push the branch", "submit the form",
      "send later", "email Andrea the plan", "post on Instagram", "publish v1",
      "share the doc link", "push it live", "submit the pre-assessment answers", "send the invoice file",
      "then email it"
    ],
    money: [
      "pay the $85 filing fee", "buy the domain", "purchase the course", "charge the card",
      "refund the order", "wire the deposit", "venmo him", "costs $15/mo", "it's $ 40",
      "pay it", "Buy two", "PURCHASE plan", "paid tier upgrade", "pays monthly",
      "charge it now", "refund please", "wire it Friday", "$2,000 minimum", "buy credits",
      "pay the LLC fee"
    ],
    regulated: [
      "copy the FERPA roster", "pull the SSN column", "export PII", "share the HIPAA report",
      "GLBA records", "PCI scope", "FTI extract", "erik.lindquist@wgu.edu inbox",
      "social security number", "ferpa check", "move the pii file", "Hipaa log",
      "the SSN list", "PCI data", "open wgu.edu mail"
    ],
    address: [
      "sign it el.3079@gmail.com", "cc eriklindquist2@gmail.com", "from erik.lindquist.ut@gmail.com",
      "reply-to a@b.co", "use jo.smith+tag@mail.example.org", "to someone@company.io",
      "list x_y@z.net", "contact me@here.us", "bcc team@corp.com", "ask ops@site.dev"
    ],
    password: [
      "make a password for Relay", "set the password", "reset passwords", "type the passcode",
      "Password: hunter2", "save the PASSWORD", "new passcodes", "password manager entry",
      "change the password", "suggest a password"
    ]
  }

  @ones [
    "", "draft the Santorini section", "rename the folder to V2", "deleted scenes list, read only",
    "the payoff chapter", "postmortem notes", "tighten the text of chapter 2", "format the table",
    "read MIND.md", "build the PDFs", "run the log audit", "outline the roadmap", "sketch the Ribbon tile",
    "list the pins", "compare V2.6 and V2.7", "summarize Ouroboros", "count the keystrokes",
    "write the README", "add a node to the Atlas", "move the file into Study", "open V3.4 FOREST",
    "check the grammar", "make a study plan", "build the flashcards", "grade the quiz",
    "plan the Texas week", "find the cemetery record", "map the zones", "draw the loop",
    "translate to 7th-grade voice", "number the next steps", "fold pin 33 in", "compact the log",
    "make the diagram grayscale-safe", "the removal of doubt is the point", "a shared vision",
    "sharpen the claim", "the postal route", "a sender-agnostic design", "the publisher's note",
    "a pushy tone", "the paycheck chapter", "buyer persona", "the charger cable", "the wire frame",
    "passage of time", "the address bar", "the submarine scene", "the emailing habit chapter",
    "a trashy novel title", "remover tool review", "overwritten prose", "erasers on the list",
    "wiper blades", "the pii-free outline", "social media calendar", "the pci-e slot",
    "the ssnake game", "ferpas", "the hipaat", "the at sign @ alone", "user@ incomplete",
    "@handle only", "pay-off", "purchaser", "chargeback theory", "rebuy ideas"
  ]

  for {reason, phrases} <- @zeros, {phrase, i} <- Enum.with_index(phrases) do
    @phrase phrase
    @reason reason
    test "0 · #{reason} ##{i}: #{inspect(phrase)}" do
      assert {:zero, @reason} == Gate.classify(@phrase)
    end
  end

  for {phrase, i} <- Enum.with_index(@ones) do
    @phrase phrase
    test "1 ##{i}: #{inspect(phrase)}" do
      assert :one == Gate.classify(@phrase)
    end
  end
end
