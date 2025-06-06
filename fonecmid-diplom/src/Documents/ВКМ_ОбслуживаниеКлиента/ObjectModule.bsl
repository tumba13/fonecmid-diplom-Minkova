
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

#КонецОбласти

#Область ПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область ОбработчикиСобытий
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	
	// Минкова - Заполнение регистра ВКМ_ВыполненныеКлиентуРаботы - 21.02.2025
		
	Запрос = Новый Запрос;
	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.Ссылка КАК Ссылка,
		|	СУММА(ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.ЧасыКОплатеКлиенту) КАК КоличествоЧасы
		|ПОМЕСТИТЬ ВТ_ВыполненныеРаботы
		|ИЗ
		|	Документ.ВКМ_ОбслуживаниеКлиента.ВыполненныеРаботы КАК ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы
		|ГДЕ
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.Ссылка = &Ссылка
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ОбслуживаниеКлиентаВыполненныеРаботы.Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВКМ_ОбслуживаниеКлиента.Клиент КАК Клиент,
		|	ВКМ_ОбслуживаниеКлиента.Договор КАК Договор,
		|	ВКМ_ОбслуживаниеКлиента.Специалист КАК Специалист,
		|	ВКМ_ОбслуживаниеКлиента.ДатаПроведенияРабот КАК ДатаПроведенияРабот,
		|	ДоговорыКонтрагентов.ВидДоговора КАК ВидДоговора,
		|	ДоговорыКонтрагентов.ВКМ_ДатаНачалаДействияДоговора КАК ВКМ_ДатаНачалаДействияДоговора,
		|	ДоговорыКонтрагентов.ВКМ_ДатаОкончанияДействияДоговора КАК ВКМ_ДатаОкончанияДействияДоговора,
		|	ЕСТЬNULL(ДоговорыКонтрагентов.ВКМ_СтоимостьЧасаРаботы, 0) КАК СтоимостьЧасаРаботы,
		|	ЕСТЬNULL(ВТ_ВыполненныеРаботы.КоличествоЧасы, 0) КАК КоличествоЧасы,
		|	ЕСТЬNULL(ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот, -1) КАК ПроцентОтРабот,
		|	ВКМ_ОбслуживаниеКлиента.Дата КАК Период
		|ИЗ
		|	Документ.ВКМ_ОбслуживаниеКлиента КАК ВКМ_ОбслуживаниеКлиента
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|		ПО ВКМ_ОбслуживаниеКлиента.Договор = ДоговорыКонтрагентов.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ВыполненныеРаботы КАК ВТ_ВыполненныеРаботы
		|		ПО ВКМ_ОбслуживаниеКлиента.Ссылка = ВТ_ВыполненныеРаботы.Ссылка
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(&Период, Сотрудник = &Специалист) КАК
		|			ВКМ_УсловияОплатыСотрудниковСрезПоследних
		|		ПО ВКМ_ОбслуживаниеКлиента.Специалист = ВКМ_УсловияОплатыСотрудниковСрезПоследних.Сотрудник
		|ГДЕ
		|	ВКМ_ОбслуживаниеКлиента.Ссылка = &Ссылка";
		
		
		
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Специалист", Специалист);
	Запрос.УстановитьПараметр("Период", Дата);
		
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Не Выборка.Следующий() Тогда
	
		Отказ = Истина;
		Возврат;
		
	КонецЕсли;
	
	
	Если Выборка.ВидДоговора <> ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание") Тогда
	
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = СтрШаблон("Выбран некорректный договор - %1.", Выборка.Договор);
		Сообщение.Сообщить();
		Отказ = Истина;
		Возврат;
		
	КонецЕсли;
	
	Если ДатаПроведенияРабот < Выборка.ВКМ_ДатаНачалаДействияДоговора Или ДатаПроведенияРабот > Выборка.ВКМ_ДатаОкончанияДействияДоговора Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = СтрШаблон("Дата проведения работ не соответсвует периоду действия договора %1.", Выборка.Договор);
		Сообщение.Сообщить();
		Отказ = Истина;
		Возврат;

	КонецЕсли;
		
	
	Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;
	
	Движение = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
	ЗаполнитьЗначенияСвойств(Движение, Выборка);
	
	
	Движение.СуммаКОплате = Выборка.СтоимостьЧасаРаботы * Выборка.КоличествоЧасы;
	Движение.КоличествоЧасов = Выборка.КоличествоЧасы;
	
	
	// Минкова - Заполнение регистра ВКМ_ВыполненныеСотрудникомРаботы - 05.03.2025
	
	Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записывать = Истина;
	
	Если Выборка.ПроцентОтРабот = -1 Тогда
		ОбщегоНазначения.СообщитьПользователю("Необходимо установить процент сотрудника оплаты от работ"); 
		Отказ = Истина;
		Возврат;
	КонецЕсли;	
	
	Движение = Движения.ВКМ_ВыполненныеСотрудникомРаботы.Добавить();
	ЗаполнитьЗначенияСвойств(Движение, Выборка);
	Движение.Сотрудник = Специалист;
	Движение.СуммаКОплате = Выборка.СтоимостьЧасаРаботы * Выборка.КоличествоЧасы * Выборка.ПроцентОтРабот / 100;
	Движение.ЧасовКОплате = Выборка.КоличествоЧасы;
	
	
	
КонецПроцедуры

	

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	// Минкова - При создании/изменении документа формирует сообщение - 01.03.2025

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;


	ДанныеДокумента = Новый Структура;
	ДанныеДокумента.Вставить("Специалист", Строка(Специалист));
	ДанныеДокумента.Вставить("НовыйДокумент", Ложь);
	ДанныеДокумента.Вставить("ДокументИзменился", Ложь);
	ДанныеДокумента.Вставить("ДатаПроведенияРабот", Формат(ДатаПроведенияРабот, "ДФ=dd.MM.yyyy;"));
	ДанныеДокумента.Вставить("ВремяНачалаРабот", Формат(ВремяНачалаРабот, "ДФ=HH:mm;"));
	ДанныеДокумента.Вставить("ВремяОкончанияРабот", Формат(ВремяОкончанияРабот, "ДФ=HH:mm;"));

	

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВКМ_ОбслуживаниеКлиента.Специалист,
		|	ВКМ_ОбслуживаниеКлиента.ДатаПроведенияРабот,
		|	ВКМ_ОбслуживаниеКлиента.ВремяНачалаРабот,
		|	ВКМ_ОбслуживаниеКлиента.ВремяОкончанияРабот
		|ИЗ
		|	Документ.ВКМ_ОбслуживаниеКлиента КАК ВКМ_ОбслуживаниеКлиента
		|ГДЕ
		|	ВКМ_ОбслуживаниеКлиента.Ссылка = &Ссылка";
		
	Запрос.УстановитьПараметр("Ссылка", Ссылка);		
	
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
		
	Если Не Выборка.Следующий() Тогда
		
		ДанныеДокумента.НовыйДокумент = Истина;
		ДанныеДокумента.ДокументИзменился = Истина;
		
	Иначе
		
		Если Выборка.Специалист <> Специалист Тогда
			ДанныеДокумента.Специалист = СтрШаблон("Изменен с %1 на %2", Выборка.Специалист, ДанныеДокумента.Специалист);			
			ДанныеДокумента.ДокументИзменился = Истина;		
		КонецЕсли;
		
		Если Выборка.ДатаПроведенияРабот <> ДатаПроведенияРабот Тогда
			ДанныеДокумента.ДатаПроведенияРабот = СтрШаблон("Изменилась с %1 на %2", Формат(Выборка.ДатаПроведенияРабот, "ДФ=dd.MM.yyyy;"), ДанныеДокумента.ДатаПроведенияРабот);			
			ДанныеДокумента.ДокументИзменился = Истина;
		КонецЕсли;
		
		Если Выборка.ВремяНачалаРабот <> ВремяНачалаРабот Тогда
			ДанныеДокумента.ВремяНачалаРабот = СтрШаблон("Изменилось с %1 на %2", Формат(Выборка.ВремяНачалаРабот, "ДФ=HH:mm;"), ДанныеДокумента.ВремяНачалаРабот);			
			ДанныеДокумента.ДокументИзменился = Истина;
		КонецЕсли;

		Если Выборка.ВремяОкончанияРабот <> ВремяОкончанияРабот Тогда
			ДанныеДокумента.ВремяОкончанияРабот = СтрШаблон("Изменилось с %1 на %2", Формат(Выборка.ВремяОкончанияРабот, "ДФ=HH:mm;"), ДанныеДокумента.ВремяОкончанияРабот);			
			ДанныеДокумента.ДокументИзменился = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если ДанныеДокумента.НовыйДокумент Тогда
		СтатусДокумента = "Новый документ"
	Иначе 
		СтатусДокумента = "Документ изменен";
	КонецЕсли;
		
	Если ДанныеДокумента.ДокументИзменился Тогда
		ТекстСообщения = СтрШаблон("Статус документа: %1. 
		|Специалист: %2. 
		|Дата проведения работ: %3.
		|Время начала работ: %4. 
		|Время окончания рабоот: %5.", 
				СтатусДокумента,
				ДанныеДокумента.Специалист,
				ДанныеДокумента.ДатаПроведенияРабот,
				ДанныеДокумента.ВремяНачалаРабот,
				ДанныеДокумента.ВремяОкончанияРабот);
				
		СформироватьТекстУведомленияТелеграмБоту(ТекстСообщения);

		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = ТекстСообщения;
		Сообщение.Сообщить();
		
	КонецЕсли;
	
КонецПроцедуры
#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Код процедур и функций

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

//// Минкова - Процедура создания элемента справочника ВКМ_УведомленияТелеграмБоту - 01.03.2025
Процедура СформироватьТекстУведомленияТелеграмБоту(ТекстСообщения)
	
	УведомлениеТелеграмБоту = Справочники.ВКМ_УведомленияТелеграмБоту.СоздатьЭлемент();
	УведомлениеТелеграмБоту.ТекстСообщения = ТекстСообщения;
	УведомлениеТелеграмБоту.Записать();	
	
КонецПроцедуры	

#КонецОбласти

#Область Инициализация

#КонецОбласти

#КонецЕсли
