'use client';

import { useMemo } from 'react';
import {
  addMonths,
  eachDayOfInterval,
  endOfMonth,
  endOfWeek,
  format,
  isSameDay,
  isSameMonth,
  startOfMonth,
  startOfWeek,
} from 'date-fns';
import { tr } from 'date-fns/locale';
import { ChevronLeft, ChevronRight, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

export type CalendarEvent = {
  id: string;
  title: string;
  date: string;
  completed?: boolean;
};

type ThreeDWallCalendarProps = {
  events: CalendarEvent[];
  month: Date;
  onMonthChange: (date: Date) => void;
  onSelectDate?: (date: Date) => void;
  selectedDate?: Date | null;
  onRemoveEvent?: (id: string) => void;
};

export function ThreeDWallCalendar({
  events,
  month,
  onMonthChange,
  onSelectDate,
  selectedDate,
  onRemoveEvent,
}: ThreeDWallCalendarProps) {
  const days = useMemo(() => {
    const start = startOfWeek(startOfMonth(month), { weekStartsOn: 1 });
    const end = endOfWeek(endOfMonth(month), { weekStartsOn: 1 });
    return eachDayOfInterval({ start, end });
  }, [month]);

  const eventsByDay = useMemo(() => {
    const map = new Map<string, CalendarEvent[]>();
    for (const ev of events) {
      const key = ev.date.slice(0, 10);
      const list = map.get(key) ?? [];
      list.push(ev);
      map.set(key, list);
    }
    return map;
  }, [events]);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <Button type="button" variant="outline" size="icon" onClick={() => onMonthChange(addMonths(month, -1))}>
          <ChevronLeft className="h-4 w-4" />
        </Button>
        <h2 className="text-lg font-bold capitalize text-slate-900">
          {format(month, 'MMMM yyyy', { locale: tr })}
        </h2>
        <Button type="button" variant="outline" size="icon" onClick={() => onMonthChange(addMonths(month, 1))}>
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>

      <div className="grid grid-cols-7 gap-1 text-center text-xs font-medium text-slate-500">
        {['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'].map((d) => (
          <div key={d} className="py-1">
            {d}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-7 gap-2 perspective-[800px]">
        {days.map((day) => {
          const key = format(day, 'yyyy-MM-dd');
          const dayEvents = eventsByDay.get(key) ?? [];
          const inMonth = isSameMonth(day, month);
          const selected = selectedDate && isSameDay(day, selectedDate);
          const depth = Math.min(dayEvents.length, 4);

          return (
            <button
              key={key}
              type="button"
              onClick={() => onSelectDate?.(day)}
              className={cn(
                'relative min-h-[72px] rounded-xl border p-1 text-left transition-transform',
                inMonth ? 'bg-white border-slate-200' : 'bg-slate-50 border-transparent opacity-50',
                selected && 'ring-2 ring-brand border-brand',
                depth > 0 && 'shadow-md hover:-translate-y-0.5',
              )}
              style={{
                transform: depth ? `translateZ(${depth * 4}px)` : undefined,
              }}
            >
              <span className="text-xs font-semibold text-slate-700">{format(day, 'd')}</span>
              <div className="mt-1 space-y-0.5">
                {dayEvents.slice(0, 2).map((ev) => (
                  <span
                    key={ev.id}
                    className={cn(
                      'block truncate rounded px-1 text-[9px] font-medium',
                      ev.completed ? 'bg-slate-200 text-slate-500 line-through' : 'bg-brand-light text-brand',
                    )}
                  >
                    {ev.title}
                  </span>
                ))}
                {dayEvents.length > 2 && (
                  <span className="text-[9px] text-slate-400">+{dayEvents.length - 2}</span>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {selectedDate && onRemoveEvent && (
        <div className="rounded-xl border border-slate-200 bg-white p-4">
          <p className="mb-2 text-sm font-semibold text-slate-900">
            {format(selectedDate, 'd MMMM yyyy', { locale: tr })}
          </p>
          <ul className="space-y-2">
            {(eventsByDay.get(format(selectedDate, 'yyyy-MM-dd')) ?? []).map((ev) => (
              <li key={ev.id} className="flex items-center justify-between gap-2 text-sm">
                <span className={ev.completed ? 'line-through text-slate-400' : 'text-slate-700'}>
                  {ev.title}
                </span>
                <Button type="button" variant="ghost" size="icon" onClick={() => onRemoveEvent(ev.id)}>
                  <Trash2 className="h-4 w-4 text-red-500" />
                </Button>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
