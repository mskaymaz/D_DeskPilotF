#pragma once

#include <QDate>
#include <QObject>
#include <QTimer>

namespace DeskPilot {

class DateService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDate currentDate READ currentDate NOTIFY currentDateChanged)

public:
    explicit DateService(QObject *parent = nullptr);

    QDate currentDate() const;

signals:
    void currentDateChanged();

private:
    void refresh();

    QTimer m_timer;
    QDate m_currentDate;
};

} // namespace DeskPilot
