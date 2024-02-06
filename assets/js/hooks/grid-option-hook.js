export const GridOptionHook  = {
    mounted() {
        let widget = this.el.getAttribute('phx-value-widget');
        let widgetSettings = this.el.getAttribute('phx-value-settings') || "{}";
        let defaultCols = this.el.getAttribute('phx-value-cols');
        let defaultRows = this.el.getAttribute('phx-value-rows');
        defaultCols = defaultCols ? parseInt(defaultCols) : 1;
        defaultRows = defaultRows ? parseInt(defaultRows) : 1;
        this.el.ondragstart = (ev) => {
            document.noizuGridState = {cols: defaultCols, rows: defaultRows};
            //ev.dataTransfer.setData(`dimensions-${defaultCols}-${defaultRows}`, '');
            ev.dataTransfer.setData("widget", widget)
            ev.dataTransfer.setData("settings", widgetSettings)
            ev.dataTransfer.setData("cols", defaultCols)
            ev.dataTransfer.setData("rows", defaultRows)
            ev.dataTransfer.setData("from", this.el.id)
            ev.dataTransfer.setData("type", "new")
        }
    }
}
