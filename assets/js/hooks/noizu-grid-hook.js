export const NoizuGridHook  = {
    dragInit() {
        let emptyCells = this.el.querySelectorAll(":scope > .noizu-grid-grid > .grid-cell.empty")
        emptyCells.forEach((cell) => {


            cell.ondragenter = (ev) => {
                let cellCol = parseInt(cell.getAttribute('cell-col'));
                let cellRow = parseInt(cell.getAttribute('cell-row'));
                let obstructed = false;
                if (document.noizuGridState.cols > 1 || document.noizuGridState.rows > 1) {
                    for (let row = 1; row < document.noizuGridState.rows; row++) {
                        for (let col = 1; col < document.noizuGridState.cols; col++) {
                            let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
                            if (!cover) {
                                // check if overlap self/cell being moved.
                                obstructed = true;
                            }
                        }
                    }
                }

                for (let row = 0; row < document.noizuGridState.rows; row++) {
                    for (let col = 0; col < document.noizuGridState.cols; col++) {
                        let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
                        if (cover) {
                            cover.classList.add("drop-selection");
                            if (obstructed) {
                                cover.classList.add("drop-obstructed");
                            }
                        }
                    }
                }

            }
            cell.ondragleave = (ev) => {
                let cellCol = parseInt(cell.getAttribute('cell-col'));
                let cellRow = parseInt(cell.getAttribute('cell-row'));
                for (let row = 0; row < document.noizuGridState.rows; row++) {
                    for (let col = 0; col < document.noizuGridState.cols; col++) {
                        let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
                        if (cover) {
                            cover.classList.remove("drop-selection");
                            cover.classList.remove("drop-obstructed");
                        }
                    }
                }
            }

            cell.ondrop = (ev) => {
                ev.preventDefault();
                let cellCol = parseInt(cell.getAttribute('cell-col'));
                let cellRow = parseInt(cell.getAttribute('cell-row'));
                let clipCol = null;
                let clipRow = null;
                for (let row = 0; row < document.noizuGridState.rows; row++) {
                    for (let col = 0; col < document.noizuGridState.cols; col++) {
                        console.log("col", col);
                        let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
                        if (cover) {
                            cover.classList.remove("drop-selection");
                            cover.classList.remove("drop-obstructed");
                        } else {
                            // check if overlap self/cell being moved.
                            if (clipCol == null) {
                                clipCol = col;
                            } else {
                                if (col < clipCol) {
                                    clipRow = row;
                                }
                            }
                        }
                    }
                    //if (clipCol == null) clipCol = document.noizuGridState.cols;
                }
                clipCol = clipCol ||  document.noizuGridState.cols
                clipRow = clipRow ||  document.noizuGridState.rows
                let type =  ev.dataTransfer.getData("type")
                let payload = {
                    clip: {cols: clipCol, rows: clipRow},
                    position: {col: cellCol, row: cellRow},
                    widget: ev.dataTransfer.getData("widget"),
                    settings: ev.dataTransfer.getData("settings"),
                    from: ev.dataTransfer.getData("from")
                }
                console.log(payload);
                if (type == "new") {
                    this.pushEvent("cell:add", payload)
                } else if (type == "move") {
                    this.pushEvent("cell:move", payload)
                }

            }

            cell.ondragstart = (ev) => {
                return false;
            }

        })

    },

    mounted() {
       document.noizuGridState = {cols: 1, rows: 1};
       this.dragInit();
    },
    updated() {
        document.noizuGridState = {cols: 1, rows: 1};
        this.dragInit();
    }
}
