//
//  Copyright (c) 2021. Adam Share
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SPIR

protocol TicTacToePresentable: Presentable {
    var listener: TicTacToePresentableListener? { get set }
    func setCell(atRow row: Int, col: Int, withPlayerType playerType: PlayerType)
    func announce(winner: PlayerType?)
}

public protocol TicTacToeListener {
    func ticTacToeDidEnd(with winner: PlayerType?)
}

final class TicTacToeInteractor: PresentableInteractor<TicTacToePresentable>, TicTacToePresentableListener {
    let listener: TicTacToeListener

    init(presenter: TicTacToePresentable,
         listener: TicTacToeListener,
         scoreRelay: ScoreRelay)
    {
        self.listener = listener
        self.scoreRelay = scoreRelay
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive(_ lifecyclePublisher: LifecyclePublisher) {
        super.didBecomeActive(lifecyclePublisher)

        initBoard()
    }

    // MARK: - TicTacToePresentableListener

    func placeCurrentPlayerMark(atRow row: Int, col: Int) {
        guard board[row][col] == nil else {
            return
        }

        let currentPlayer = getAndFlipCurrentPlayer()
        board[row][col] = currentPlayer
        presenter.setCell(atRow: row, col: col, withPlayerType: currentPlayer)

        let endGame = checkEndGame()
        if endGame.didEnd {
            if let winner = endGame.winner {
                scoreRelay.updateScore(with: winner)
            }

            presenter.announce(winner: endGame.winner)
        }
    }

    func closeGame(winner: PlayerType?) {
        listener.ticTacToeDidEnd(with: winner)
    }

    // MARK: - Private

    private let scoreRelay: ScoreRelay

    private var currentPlayer = PlayerType.player1
    private var board = [[PlayerType?]]()

    private func initBoard() {
        for _ in 0 ..< GameConstants.rowCount {
            board.append([nil, nil, nil])
        }
    }

    private func getAndFlipCurrentPlayer() -> PlayerType {
        let currentPlayer = self.currentPlayer
        self.currentPlayer = currentPlayer == .player1 ? .player2 : .player1
        return currentPlayer
    }

    private func checkEndGame() -> (winner: PlayerType?, didEnd: Bool) {
        let winner = checkWinner()
        if let winner = winner {
            return (winner, true)
        }
        let isDraw = checkDraw()
        if isDraw {
            return (nil, true)
        }

        return (nil, false)
    }

    private func checkWinner() -> PlayerType? {
        // Rows.
        for row in 0 ..< GameConstants.rowCount {
            guard let assumedWinner = board[row][0] else {
                continue
            }
            var winner: PlayerType? = assumedWinner
            for col in 1 ..< GameConstants.colCount {
                if assumedWinner.rawValue != board[row][col]?.rawValue {
                    winner = nil
                    break
                }
            }
            if let winner = winner {
                return winner
            }
        }

        // Cols.
        for col in 0 ..< GameConstants.colCount {
            guard let assumedWinner = board[0][col] else {
                continue
            }
            var winner: PlayerType? = assumedWinner
            for row in 1 ..< GameConstants.rowCount {
                if assumedWinner.rawValue != board[row][col]?.rawValue {
                    winner = nil
                    break
                }
            }
            if let winner = winner {
                return winner
            }
        }

        // Diagnals.
        guard let p11 = board[1][1] else {
            return nil
        }
        if let p00 = board[0][0], let p22 = board[2][2] {
            if p00.rawValue == p11.rawValue, p11.rawValue == p22.rawValue {
                return p11
            }
        }

        if let p02 = board[0][2], let p20 = board[2][0] {
            if p02.rawValue == p11.rawValue, p11.rawValue == p20.rawValue {
                return p11
            }
        }

        return nil
    }

    private func checkDraw() -> Bool {
        for row in 0 ..< GameConstants.rowCount {
            for col in 0 ..< GameConstants.colCount {
                if board[row][col] == nil {
                    return false
                }
            }
        }
        return true
    }
}

enum GameConstants {
    static let rowCount = 3
    static let colCount = 3
}
