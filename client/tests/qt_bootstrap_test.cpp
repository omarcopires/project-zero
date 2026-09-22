#include <QCoreApplication>
#include <QObject>
#include <QtTest>

class QtBootstrapTest final : public QObject {
    Q_OBJECT

private slots:
    void providesCoreApplication();
};

void QtBootstrapTest::providesCoreApplication()
{
    QVERIFY(QCoreApplication::instance() != nullptr);
}

QTEST_GUILESS_MAIN(QtBootstrapTest)

#include "qt_bootstrap_test.moc"
