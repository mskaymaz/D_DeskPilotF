#pragma once

#include <QObject>
#include <QPointer>
#include <QRect>
#include <QVariantList>
#include <QVector>

class QWindow;

namespace DeskPilot {

class WindowInputMaskController final : public QObject
{
    Q_OBJECT

public:
    explicit WindowInputMaskController(QObject *parent = nullptr);

    void setWindow(QWindow *window);

    Q_INVOKABLE void setRegions(const QVariantList &regions);

private:
    void applyRegion();

    QPointer<QWindow> m_window;
    QVector<QRect> m_regions;
};

} // namespace DeskPilot
