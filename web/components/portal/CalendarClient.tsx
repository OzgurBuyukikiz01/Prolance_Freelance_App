'use client';

import { useMemo, useState, useTransition } from 'react';
import { ThreeDWallCalendar, type CalendarEvent } from '@/components/ui/three-dwall-calendar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { createScheduleItem, deleteScheduleItem } from '@/app/portal/calendar/actions';

export type ScheduleRow = {
  id: string;
  title: string;
  due_date: string;
  job_id: string;
  job_title: string;
  completed_at: string | null;
};

type CalendarClientProps = {
  items: ScheduleRow[];
  jobs: { id: string; title: string }[];
};

export function CalendarClient({ items, jobs }: CalendarClientProps) {
  const [month, setMonth] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [pending, startTransition] = useTransition();

  const events: CalendarEvent[] = useMemo(
    () =>
      items.map((item) => ({
        id: item.id,
        title: item.job_title ? `${item.title} · ${item.job_title}` : item.title,
        date: item.due_date,
        completed: Boolean(item.completed_at),
      })),
    [items],
  );

  const handleRemove = (id: string) => {
    const fd = new FormData();
    fd.set('id', id);
    startTransition(() => {
      void deleteScheduleItem(fd);
    });
  };

  const defaultDue = selectedDate
    ? selectedDate.toISOString().slice(0, 10)
    : new Date().toISOString().slice(0, 10);

  return (
    <div className="space-y-8">
      <ThreeDWallCalendar
        events={events}
        month={month}
        onMonthChange={setMonth}
        onSelectDate={setSelectedDate}
        selectedDate={selectedDate}
        onRemoveEvent={handleRemove}
      />

      <form action={createScheduleItem} className="rounded-2xl border border-slate-200 bg-white p-5 space-y-4">
        <h3 className="font-bold text-slate-900">Yeni görev</h3>
        <div className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-1.5 sm:col-span-2">
            <Label htmlFor="job_id">İş</Label>
            <select
              id="job_id"
              name="job_id"
              required
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
              defaultValue={jobs[0]?.id ?? ''}
            >
              {jobs.map((j) => (
                <option key={j.id} value={j.id}>
                  {j.title}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="title">Başlık</Label>
            <Input id="title" name="title" required placeholder="Teslim / kontrol" />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="due_date">Tarih</Label>
            <Input id="due_date" name="due_date" type="date" required defaultValue={defaultDue} />
          </div>
        </div>
        <Button type="submit" disabled={pending || !jobs.length}>
          Görev ekle
        </Button>
        {!jobs.length && (
          <p className="text-xs text-slate-500">Takvime görev eklemek için kabul edilmiş bir işiniz olmalı.</p>
        )}
      </form>
    </div>
  );
}
