/** Generate N evenly spaced milestone rows from proposal delivery_days. */
export function buildMilestoneRows(
  jobId: string,
  proposalId: string,
  deliveryDays: number,
  freelancerId: string,
  createdBy: string,
) {
  const count = Math.min(Math.max(Math.ceil(deliveryDays / 7), 1), 6);
  const start = new Date();
  const rows = [];

  for (let i = 0; i < count; i += 1) {
    const due = new Date(start);
    const step = Math.floor(deliveryDays / count);
    due.setDate(due.getDate() + step * (i + 1));
    rows.push({
      job_id: jobId,
      proposal_id: proposalId,
      title: `Kilometre taşı ${i + 1}/${count}`,
      due_date: due.toISOString().slice(0, 10),
      assignee_id: freelancerId,
      created_by: createdBy,
      sort_order: i,
    });
  }

  return rows;
}
