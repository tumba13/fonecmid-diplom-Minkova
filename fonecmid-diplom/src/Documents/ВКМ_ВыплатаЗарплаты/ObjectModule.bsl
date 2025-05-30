
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

#КонецОбласти

#Область ПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытий
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ВыплатаЗарплатыВыплаты.Сотрудник,
		|	СУММА(ВКМ_ВыплатаЗарплатыВыплаты.Сумма) КАК Сумма
		|ИЗ
		|	Документ.ВКМ_ВыплатаЗарплаты.Выплаты КАК ВКМ_ВыплатаЗарплатыВыплаты
		|ГДЕ
		|	ВКМ_ВыплатаЗарплатыВыплаты.Ссылка = &Ссылка
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ВыплатаЗарплатыВыплаты.Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	
	// Заполнение РН ВКМ_ВзаиморасчетыССотрудниками
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.Сумма = Выборка.Сумма;
	КонецЦикла;
	
	
КонецПроцедуры
#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ЗаполнитьДокумент() Экспорт
	
	Выплаты.Очистить();
	
	Запрос = Новый Запрос;
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник,
		|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток КАК Сумма
		|ИЗ
		|	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки(&Период,) КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки";
	
	Запрос.УстановитьПараметр("Период", КонецДня(Дата));
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Выплата = Выплаты.Добавить();
		ЗаполнитьЗначенияСвойств(Выплата, Выборка);
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Код процедур и функций

#КонецОбласти

#Область Инициализация

#КонецОбласти

#КонецЕсли
