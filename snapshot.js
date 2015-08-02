#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.frontMostApp().mainWindow().scrollViews()[0].textFields()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("grampe\nqwe123\n");

target.delay(10)
captureLocalizedScreenshot('0_my_serials')

target.frontMostApp().mainWindow().collectionViews()[0].cells().firstWithName("1").tap();

target.delay(10)
captureLocalizedScreenshot('1_serial_seasons')

target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.50, y:0.29}});

target.delay(10)
captureLocalizedScreenshot('2_serial_description')

target.frontMostApp().mainWindow().textViews()[0].buttons()["Schedule"].tap();

target.delay(10)
captureLocalizedScreenshot('3_serial_schedule')

target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.28, y:0.29}});
target.frontMostApp().mainWindow().collectionViews()[0].cells()[0].tap();

target.delay(10)
captureLocalizedScreenshot('4_season')

target.frontMostApp().navigationBar().buttons()["back"].tap();
target.delay(2)
target.frontMostApp().navigationBar().buttons()["back"].tap();
target.delay(2)
target.frontMostApp().toolbar().buttons()["Все"].tap();

target.delay(10)
captureLocalizedScreenshot('5_all_serials')

target.frontMostApp().toolbar().buttons()["Расписание"].tap();
target.delay(10)
captureLocalizedScreenshot('5_schedule')