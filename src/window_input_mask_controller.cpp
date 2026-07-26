#include "window_input_mask_controller.h"

#include <QRect>
#include <QVariantMap>
#include <QWindow>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

namespace DeskPilot {

WindowInputMaskController::WindowInputMaskController(QObject *parent)
    : QObject(parent)
{
}

void WindowInputMaskController::setWindow(QWindow *window)
{
    m_window = window;
    applyRegion();
}

void WindowInputMaskController::setRegions(const QVariantList &regions)
{
    m_regions.clear();

    for (const QVariant &regionValue : regions) {
        const QVariantMap region = regionValue.toMap();
        const qreal width = region.value("width").toReal();
        const qreal height = region.value("height").toReal();
        if (width <= 0 || height <= 0) {
            continue;
        }

        m_regions.append(QRect(
            qRound(region.value("x").toReal()),
            qRound(region.value("y").toReal()),
            qRound(width),
            qRound(height)));
    }

    applyRegion();
}

#ifdef Q_OS_WIN
void WindowInputMaskController::applyRegion()
{
    if (m_window == nullptr) {
        return;
    }

    const auto windowHandle = reinterpret_cast<HWND>(m_window->winId());
    if (windowHandle == nullptr) {
        return;
    }

    if (m_regions.isEmpty()) {
        SetWindowRgn(windowHandle, nullptr, TRUE);
        return;
    }

    const qreal devicePixelRatio = m_window->devicePixelRatio();
    HRGN combinedRegion = CreateRectRgn(0, 0, 0, 0);
    for (const QRect &region : m_regions) {
        const int left = qFloor(region.left() * devicePixelRatio) - 2;
        const int top = qFloor(region.top() * devicePixelRatio) - 2;
        const int right = qCeil((region.right() + 1) * devicePixelRatio) + 2;
        const int bottom = qCeil((region.bottom() + 1) * devicePixelRatio) + 2;
        HRGN moduleRegion = CreateRectRgn(left, top, right, bottom);
        CombineRgn(combinedRegion, combinedRegion, moduleRegion, RGN_OR);
        DeleteObject(moduleRegion);
    }

    if (SetWindowRgn(windowHandle, combinedRegion, TRUE) == 0) {
        DeleteObject(combinedRegion);
    }
}
#else
void WindowInputMaskController::applyRegion()
{
}
#endif

} // namespace DeskPilot
