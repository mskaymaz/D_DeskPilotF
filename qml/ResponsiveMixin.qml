import QtQuick 2.0

QtObject {
    // Provides a convenient scaling helper based on the global design scale
    property real globalScale: DesignTokens.globalScale
    function rs(value) {
        return Math.round(value * globalScale)
    }
}
