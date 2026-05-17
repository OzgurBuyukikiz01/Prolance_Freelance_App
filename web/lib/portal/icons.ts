import {
  Briefcase,
  MessageSquare,
  CreditCard,
  Package,
  RefreshCw,
  Clock,
  DollarSign,
  CheckCircle2,
  Flag,
  AlertTriangle,
  Bell,
  FileText,
  Download,
} from 'lucide-react';

export const NOTIFICATION_ICONS = {
  job: Briefcase,
  message: MessageSquare,
  payment: CreditCard,
  proposal: Briefcase,
  system: Bell,
  default: Bell,
} as const;

export const DELIVERY_ICONS = {
  package: Package,
  document: FileText,
  download: Download,
} as const;

export const STATUS_ICONS = {
  escrow_funded: RefreshCw,
  awaiting_client_review: Clock,
  payout_pending: DollarSign,
  closed: CheckCircle2,
  disputed: AlertTriangle,
} as const;

export type NotificationType = keyof typeof NOTIFICATION_ICONS;
export type DeliveryIconType = keyof typeof DELIVERY_ICONS;
export type StatusIconType = keyof typeof STATUS_ICONS;

export function getNotificationIcon(type: string | null) {
  return NOTIFICATION_ICONS[type as NotificationType] || NOTIFICATION_ICONS.default;
}

export function getStatusIcon(status: string) {
  return STATUS_ICONS[status as StatusIconType] || RefreshCw;
}
