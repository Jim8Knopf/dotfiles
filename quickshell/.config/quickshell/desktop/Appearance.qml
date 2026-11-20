import QtQuick

QtObject {
    required property var controller
    function rows(theme, wall, walls, data) {
            let result = data.themes.map(function(item) {
                return {title: item.title, detail: theme === item.id ? "Current theme" : item.detail, image: item.wallpaper, cmd: [controller.configHome + "/hypr/scripts/desktop", "theme", item.id]}
            })
            result.push({title:"Use theme wallpaper", detail: wall ? "Clear wallpaper override" : "Current wallpaper follows theme", cmd:[controller.configHome + "/hypr/scripts/desktop", "wallpaper", "reset"]})
            for (let i = 0; i < walls.length; i++) {
                let file = walls[i]
                result.push({title: file.split("/").pop(), detail: wall === file ? "Current wallpaper" : "Set wallpaper independently", image: file, cmd: [controller.configHome + "/hypr/scripts/desktop", "wallpaper", "set", file]})
            }
            return result
    }
}
