import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shift_calendar/model/shift_data_model.dart';
import 'package:shift_calendar/provider/shift_calendar_provider.dart';
import 'package:shift_calendar/utils/event_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTable extends HookConsumerWidget {
  late ValueNotifier<List<EventUtils>> _selectedEvents; // 選択イベント
  CalendarFormat _calendarFormat = CalendarFormat.month; // 表示月
  DateTime _focusedDay = DateTime.now(); // フォーカスは本日固定

  List<EventUtils> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // カレンダーイベント設定
    var selectedDate = useState<DateTime?>(DateTime.now());
    // カレンダー取得(監視)
    List<ShiftDataModel> listItems = ref.watch(shiftCalendarProvider);
    // カレンダーイベント設定
    setCalendarEvent(listItems);
    // イベント設定
    _selectedEvents = ValueNotifier(_getEventsForDay(selectedDate.value!));
    return Scaffold(
      body: Column(
        children: [
          TableCalendar<EventUtils>(
            locale: 'ja_JP', // 日本語
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDate.value!, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // 表示変更不可
            ),
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              // 日付選択(カレンダー更新)
              selectedDate.value = selectedDay;
              _selectedEvents.value = _getEventsForDay(selectedDay);
            }, // 日を選択
            calendarBuilders: CalendarBuilders(// 曜日をフォーマット
                dowBuilder: (_, day) {
              if (day.weekday == DateTime.sunday) {
                // 日曜
                return const Center(
                  child: Text(
                    '日',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (day.weekday == DateTime.saturday) {
                return const Center(
                  child: Text(
                    '土',
                    style: TextStyle(color: Colors.blue),
                  ),
                );
              }
            }),
            onPageChanged: (focusedDay) {
              // ページ切り替え
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<EventUtils>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
