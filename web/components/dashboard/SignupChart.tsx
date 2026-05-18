'use client';

import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';

export type SignupChartPoint = {
  date: string;
  signups: number;
};

type SignupChartProps = {
  data: SignupChartPoint[];
};

export function SignupChart({ data }: SignupChartProps) {
  return (
    <div className="glass-card p-6">
      <div className="mb-4">
        <h2 className="text-sm font-semibold text-slate-200">Signups — Last 7 Days</h2>
        <p className="text-xs text-slate-500 mt-0.5">New user profiles</p>
      </div>
      <div className="h-[240px] w-full">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
            <defs>
              <linearGradient id="signupFill" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#7248FE" stopOpacity={0.45} />
                <stop offset="95%" stopColor="#7248FE" stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#334155" vertical={false} />
            <XAxis
              dataKey="date"
              tick={{ fill: '#94a3b8', fontSize: 12 }}
              axisLine={false}
              tickLine={false}
            />
            <YAxis
              allowDecimals={false}
              tick={{ fill: '#94a3b8', fontSize: 12 }}
              axisLine={false}
              tickLine={false}
              width={32}
            />
            <Tooltip
              contentStyle={{
                background: '#0f172a',
                border: '1px solid #334155',
                borderRadius: 12,
                color: '#e2e8f0',
              }}
              labelStyle={{ color: '#94a3b8' }}
            />
            <Area
              type="monotone"
              dataKey="signups"
              stroke="#7248FE"
              strokeWidth={2}
              fill="url(#signupFill)"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
