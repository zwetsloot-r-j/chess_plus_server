defmodule ChessPlus.ObserverRegistry do
  use ChessPlus.Observers

  @observers [
    player_created: [
      ChessPlus.Flow.PlayerRegistry.RegisterPlayer
    ],
    player_deleted: [
      ChessPlus.Flow.PlayerRegistry.UnregisterPlayer
    ],
    duel_created: [
      ChessPlus.Flow.OpenDuelRegistry.RegisterDuel
    ],
    duel_joined: [
      ChessPlus.Flow.Player.JoinDuel
    ],
    duel_left: [
      ChessPlus.Flow.Player.LeaveDuel
    ]
  ]
end
