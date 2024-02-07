export const NoizuGridHook  = {
    clipBox(col, row, width, height) {
    //
    //     let clipCol = null;
    //     let clipRow = null;
    //     for (let row = 0; row < document.noizuGridState.rows; row++) {
    //     for (let col = 0; col < document.noizuGridState.cols; col++) {
    //         console.log("col", col);
    //         let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
    //         if (cover) {
    //             cover.classList.remove("drop-selection");
    //             cover.classList.remove("drop-obstructed");
    //         } else {
    //             // check if overlap self/cell being moved.
    //             if (clipCol == null) {
    //                 clipCol = col;
    //             } else {
    //                 if (col < clipCol) {
    //                     clipRow = row;
    //                 }
    //             }
    //         }
    //     }
    //     //if (clipCol == null) clipCol = document.noizuGridState.cols;
    // }
    //     clipCol = clipCol ||  document.noizuGridState.cols
    //     clipRow = clipRow ||  document.noizuGridState.rows
        return {cols: width, rows: height}
    },
    dragInit() {
        let gridCols = parseInt(this.el.getAttribute('phx-value-cols'));
        let gridRows = parseInt(this.el.getAttribute('phx-value-rows'));

        let emptyCells = this.el.querySelectorAll(":scope > .noizu-grid-grid > .grid-cell.empty")


        this.el.addEventListener('dragenter', (event) => {
            this.el.classList.add('dragging')

            if (event.target.classList.contains("grid-cell")) {
                let cell = event.target;
                let cellCol = parseInt(cell.getAttribute('cell-col'));
                let cellRow = parseInt(cell.getAttribute('cell-row'));
                let obstructed = false;
                if (document.noizuGridState.cols > 1 || document.noizuGridState.rows > 1) {
                    for (let row = 0; row < document.noizuGridState.rows; row++) {
                        for (let col = 0; col < document.noizuGridState.cols; col++) {
                            let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"][cell-populated="false"]`);
                            if (!cover) {
                                // check if overlap self/cell being moved.
                                obstructed = true;
                            }
                        }
                    }
                }

                cell.classList.add(`col-span-${document.noizuGridState.cols}`)
                cell.classList.add(`row-span-${document.noizuGridState.rows}`)
                cell.classList.add("drop-selection");
                if (obstructed) {
                    cell.classList.add("drop-obstructed");
                }




            }


        })

        this.el.addEventListener('dragleave', (event) => {
            //this.el.classList.remove('dragging')
        })



        emptyCells.forEach((cell) => {

            //
            // cell.ondragenter = (ev) => {
            //     let cellCol = parseInt(cell.getAttribute('cell-col'));
            //     let cellRow = parseInt(cell.getAttribute('cell-row'));
            //     let obstructed = false;
            //     if (document.noizuGridState.cols > 1 || document.noizuGridState.rows > 1) {
            //         for (let row = 0; row < document.noizuGridState.rows; row++) {
            //             for (let col = 0; col < document.noizuGridState.cols; col++) {
            //                 let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"][cell-populated="false"]`);
            //                 if (!cover) {
            //                     // check if overlap self/cell being moved.
            //                     obstructed = true;
            //                 }
            //             }
            //         }
            //     }
            //
            //     cell.classList.add(`col-span-${document.noizuGridState.cols}`)
            //     cell.classList.add(`row-span-${document.noizuGridState.rows}`)
            //     cell.classList.add("drop-selection");
            //     if (obstructed) {
            //         cell.classList.add("drop-obstructed");
            //     }
            //
            //     // for (let row = 0; row < document.noizuGridState.rows; row++) {
            //     //     for (let col = 0; col < document.noizuGridState.cols; col++) {
            //     //         let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
            //     //         if (cover) {
            //     //             cover.classList.add("drop-selection");
            //     //             if (obstructed) {
            //     //                 cover.classList.add("drop-obstructed");
            //     //             }
            //     //         }
            //     //     }
            //     // }
            //
            // }

            cell.ondragleave = (ev) => {
                let cellCol = parseInt(cell.getAttribute('cell-col'));
                let cellRow = parseInt(cell.getAttribute('cell-row'));
                cell.classList.remove(`col-span-${document.noizuGridState.cols}`)
                cell.classList.remove(`row-span-${document.noizuGridState.rows}`)
                cell.classList.remove("drop-selection");
                cell.classList.remove("drop-obstructed");
                //
                // for (let row = 0; row < document.noizuGridState.rows; row++) {
                //     for (let col = 0; col < document.noizuGridState.cols; col++) {
                //         let cover = this.el.querySelector(`:scope > .noizu-grid-grid >  .grid-cell[cell-col="${cellCol + col}"][cell-row="${cellRow + row}"]`);
                //         if (cover) {
                //             cover.classList.remove("drop-selection");
                //             cover.classList.remove("drop-obstructed");
                //         }
                //     }
                // }
            }

            cell.ondrop = (ev) => {
                ev.preventDefault();
                let cellCol = parseInt(cell.getAttribute('cell-col'));
                let cellRow = parseInt(cell.getAttribute('cell-row'));
                let clip = this.clipBox(cellCol, cellRow, document.noizuGridState.cols, document.noizuGridState.rows);

                let type =  ev.dataTransfer.getData("type")
                let identifier = ev.dataTransfer.getData("identifier")
                if (identifier == "") identifier = null;
                let payload = {
                    identifier: identifier,
                    clip: clip,
                    position: {col: cellCol, row: cellRow},
                    widget: ev.dataTransfer.getData("widget"),
                    settings: ev.dataTransfer.getData("settings"),
                    from: ev.dataTransfer.getData("from")
                }

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
        //this.dragInit();
    }
}
