#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.frontMostApp().mainWindow().scrollViews()[0].textFields()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString("grampe");
target.frontMostApp().mainWindow().scrollViews()[0].textFields()[0].textFields()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].textFields()[0].textFields()[0].tap();
target.frontMostApp().keyboard().keys()["Delete"].tap();
target.frontMostApp().keyboard().typeString("e");
target.frontMostApp().mainWindow().scrollViews()[0].secureTextFields()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString("qwe123");
target.frontMostApp().mainWindow().scrollViews()[0].buttons()["Войти"].tap();

target.delay(10)
captureLocalizedScreenshot('0')

target.frontMostApp().mainWindow().collectionViews()[0].cells().firstWithName("1").tap();

target.delay(10)
captureLocalizedScreenshot('1')

target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.47, y:0.29}});

target.delay(10)
captureLocalizedScreenshot('2')

target.frontMostApp().mainWindow().textViews()["Доктор Грегори Хаус (Хью Лори) – выдающийся врач и злой гений, который не отличается проникновенностью в общении с больными и коллегами и с удовольствием избегает и тех, и других, однако при этом способен привести к успеху самые запутанные медицинские случаи.\n\nВсе свое время Хаус проводит в борьбе с собственной болью, которая порождает его жесткую ядовитую манеру общения.\n\nПорой его поведение можно назвать почти бесчеловечным («Мама, а кто это? Это, сынок — подонок, который спас тебе жизнь»), но при этом он прекрасный врач, обладающий нестандартным мышлением и уникальным чутьем, что снискало ему глубокое уважение в кругу коллег и востребованность среди пациентов.\n\nВ больнице Принстон-Плейнсборо Хаус возглавляет элитную команду диагностов, которая занимается исключительными медицинскими случаями. В команде Хауса работают ведущие эксперты различных областей медицины: невролог Эрик Форман (Омар Эппс), хирург Роберт Чейз (Джесси Спенсер), терапевт Реми Хадли «Тринадцать» (Оливия Уайлд), пластический хирург Крис Тауб (Питер Джейкобсон).\n\nСтаринный друг Хауса, онколог доктор Джеймс Уилсон (Роберт Шон Леонард), не смотря на постоянные колкости и двусмысленные выходки Хауса, всегда старается помочь ему и оправдать Хауса даже в самой критической ситуации. А главврач клиники доктор Лиза Кадди (Лиза Эдльштейн) терпит возмутительные поступки Хауса не только из-за его профессионального потенциала и выдающихся показателей по «раскрываемости» бесперспективных случаев…"].buttons()["Расписание"].tap();

target.delay(10)
captureLocalizedScreenshot('3')

target.frontMostApp().mainWindow().tableViews()[0].tapWithOptions({tapOffset:{x:0.26, y:0.30}});
target.delay(1)

target.frontMostApp().mainWindow().collectionViews()[0].cells().firstWithName("1").tap();
target.delay(10)
captureLocalizedScreenshot('4')

target.frontMostApp().navigationBar().buttons()["back"].tap();
target.delay(1)

target.frontMostApp().navigationBar().buttons()["back"].tap();
target.delay(1)

target.frontMostApp().toolbar().buttons()["Все"].tap();
target.delay(10)
captureLocalizedScreenshot('5')

target.frontMostApp().navigationBar().searchBars()[0].searchBars()[0].tap();
target.delay(1)
target.frontMostApp().keyboard().typeString("100");
target.delay(10)
captureLocalizedScreenshot('5')

target.frontMostApp().navigationBar().buttons()["Cancel"].tap();
target.delay(1)

target.frontMostApp().toolbar().buttons()["Расписание"].tap();
target.delay(10)
captureLocalizedScreenshot('6')

target.frontMostApp().navigationBar().buttons()["settings"].tap();
target.delay(10)
captureLocalizedScreenshot('7')

