<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Minesweeper</title>
    <link rel="stylesheet" href="doodle.css">


    <style>
        @import url('https://fonts.googleapis.com/css2?family=Short+Stack&display=swap');

        * {
            margin: 0;
            user-select: none;
            font-family: 'Short Stack', cursive;
        }

        body {
            margin: 0;
            background: #ffffff;
            color: rgb(0, 0, 0);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .background {
            z-index: -1;
            position: fixed;
            inset: -70%;
            background: url(tea.png);
            background-size: 112px;
            background-repeat: repeat;
            transform: rotate(-35deg);
            opacity: 0.5;


        }

        .game {
            border: #3c7ec450 solid 5px;
            border-style: solid;
            border-width: 15px 15px 15px 15px;
            border-image: url("border.svg") 10 10 10 10 stretch stretch;
            text-align: center;
            background-color: white;
            filter: drop-shadow(0px 0px 50px rgba(93, 93, 93, 0.417));
            padding: 15px;
            border-radius: 1rem;

        }

        #board {
            display: grid;
            grid-template-columns: repeat(10, 40px);
            gap: 3px;
            margin-top: 5px;
            padding: 5px;
            background: #efefef;

        }

        .cell {
            width: 40px;
            height: 40px;
            background: #d7d7d7;
            border: 0 solid white;
            color: rgb(61, 61, 61);
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            border-radius: 0.2rem;
            transition: all 0.2s;
        }

        h1 {color: #3c7ec48b;}

        .reveal {
            background: rgb(255, 255, 255);
            border: 2px solid white !important;
        }

        .flag {
            background: #3c7ec450;
        }

        .mine {background: #c43c3e50 !important;}
        .win {background: #50c43c50;}

        button.restart {
            margin-top: 12px;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border: 0;

        }

        .status {
            display: flex;
            justify-content: space-between;
            padding: 0px 30px;
            margin: 10px 0px;
        }
    </style>
</head>

<body>

    <div class="background"></div>
    <div class="game doodle">
        
        <h1>Sea Minesweeper</h1>
        <div class="status">
            <div id="flags">(⚑) 15</div>
            <div id="timer">000</div>
        </div>

        <div id="board"></div>
        <button class="restart" onclick="startGame()">⟳</button>
        <button class="restart" id="flagswitch">*</button>
    </div>

    <script>
        const rows = 10;
        const cols = 10;
        const minesCount = 10;

        const colors = [
            "#1a7ec4",
            "#3c5ec9",
            "#3c3ec4"
        ];

        let board = [];
        let gameOver = false;
        const totalCells = rows * cols;
        const safeCells = totalCells - minesCount;
        let revSafeCells = 0;
        let flags = 0;
        let timer = 0;
        let timerId = null;
        let gameStarted = false;
        const flagElement = document.getElementById("flags");
        const timerElement = document.getElementById("timer");
        const boardElement = document.getElementById("board");
        const statusElement = document.getElementById("status");
        const flagswitchElement = document.getElementById("flagswitch");

        let canFlag = false;

        function switchMode() {
            canFlag = !canFlag;
            if (canFlag) {
                flagswitchElement.innerHTML = "⚑";
            }
            else {
                flagswitchElement.innerHTML = "*";
            }
        }

        function winGame() {
            clearInterval(timerId);
            gameOver = true;
            revealMines("win");
        }
        function loseGame() {
            clearInterval(timerId);
            gameOver = true;
        }
        function calculateNumber(r, c) {
            let count = 0;
            for (let nr = -1; nr < 2; nr++) {
                for (let nc = -1; nc < 2; nc++) {
                    if (board[r + nr] && board[c + nc] && board[r + nr][c + nc]["mine"]) {
                        count += 1;
                    }

                }
            }
            return count;
        }

        function startTimer() {

            timerId = setInterval(() => {
                timer++;
                timerElement.textContent = String(timer).padStart(3, "0");

            }, 1000);
        }

        function revealMines(state) {
            for (r = 0; r < rows; r++) {
                for (c = 0; c < cols; c++) {
                    if (board[r][c]["mine"]) {
                        const button = getButton(r, c);

                        button.classList.add(state)
                        button.innerHTML = "*";
                    }
                }
            }
        }
        function revealCell(r, c) {
            if (!gameStarted) {
                gameStarted = true;
                startTimer();
            }
            if (gameOver || board[r][c]["revealed"] || board[r][c]["flagged"]) return;
            const button = getButton(r, c);

            if (board[r][c]["mine"]) {

                revealMines("mine");
                loseGame();
                return;
            }

            board[r][c]["revealed"] = true;
            button.classList.add("reveal");
            revSafeCells++;
            console.log(revSafeCells);
            console.log(safeCells);
            if (revSafeCells === safeCells) {
                winGame();
            }
            let count = calculateNumber(r, c);
            if (count == 0) {
                for (let nr = -1; nr < 2; nr++) {
                    for (let nc = -1; nc < 2; nc++) {
                        if (board[r + nr] && board[c + nc] && !board[r + nr][c + nc]["revealed"]) {
                            if (board[r + nr][c + nc]["flagged"]) { toggleFlag(r + nr, c + nc) }
                            revealCell(r + nr, c + nc);

                        }
                    }
                }
            } else {
                button.style.color = colors[count - 1];
                button.innerHTML = count;
            }


        }
        flagswitchElement.addEventListener("pointerdown", (e) => {
            e.preventDefault();
            if (e.button === 0 || e.pointerType === "touch") {
                switchMode();


            }
        });
        function toggleFlag(r, c) {
            if (gameOver) return;
            const cell = board[r][c];
            if (cell.revealed) return;
            cell.flagged = !cell.flagged;
            const button = getButton(r, c);
            if (cell.flagged) {
                flags--;
                button.textContent = "⚑";
                button.classList.add("flag");
            } else {
                flags++;
                button.textContent = "";
                button.classList.remove("flag");
            }
            flagElement.innerText = "(⚑) " + flags
        }

        function getButton(r, c) {
            return document.querySelector(
                `[data-row="${r}"][data-col="${c}"]`
            );
        }

        function mines() {
            let r = 0;
            let c = 0;
            for (i = 0; i < minesCount; i++) {
                while (board[r][c]["mine"] == true) {
                    r = Math.floor(Math.random() * rows);
                    c = Math.floor(Math.random() * cols);
                };
                board[r][c]["mine"] = true;
                const button = getButton(r, c);
                //    button.innerHTML = "";
            }
        }
        function clickHandler(r, c) {
            if (canFlag) {
                toggleFlag(r, c);
            }
            else {
                revealCell(r, c);
            }

        }

        function setupBoard() {
            clearInterval(timerId);
            timer = 0;
            gameStarted = false;
            gameOver = false;
            revSafeCells = 0;
            flags = minesCount;
            flagElement.innerText = "(⚑) " + flags;
            timerElement.innerText = String().padStart(3, "0");
            boardElement.innerHTML = '';

            for (let r = 0; r < rows; r++) {
                board[r] = [];
                for (let c = 0; c < cols; c++) {
                    const cell = {
                        mine: false,
                        revealed: false,
                        flagged: false
                    };
                    board[r][c] = cell;

                    const button = document.createElement("button");
                    button.className = "cell";
                    button.dataset.row = r;
                    button.dataset.col = c;
                    button.addEventListener("pointerdown", (e) => {
                        if (e.button === 0 || e.pointerType === "touch") { // left click
                            clickHandler(r, c);
                        } else if (e.button === 2) { // right click
                            e.preventDefault();
                            toggleFlag(r, c);
                        }
                    });

                    boardElement.appendChild(button);
                }
            }
        }

        function startGame() {
            setupBoard();
            mines();
        }
        startGame();
    </script>

</body>

</html>