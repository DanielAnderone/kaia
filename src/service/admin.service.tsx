// src/services/admin.service.ts
import { type AdminStats, type RecentActivity } from '../models/model';

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

export class AdminService {
  async fetchStats(): Promise<AdminStats[]> {
    await sleep(500);
    return [
      { title: 'Total Investors', value: '1,234', icon: 'groups' },
      { title: 'Total Invested', value: '$5,678,901', icon: 'account_balance_wallet' },
      { title: 'Distributed Profit', value: '$1,234,567', icon: 'paid' },
      { title: 'Active Projects', value: '56', icon: 'compost' },
    ];
  }

  async fetchRecentActivity(): Promise<RecentActivity[]> {
    await sleep(500);
    return [
      { icon: 'person_add', description: 'New user registered: John Doe', timeAgo: '2 hours ago' },
      { icon: 'attach_money', description: 'Jane Smith invested $5,000 in Farm A', timeAgo: '5 hours ago' },
      { icon: 'notifications', description: 'System update scheduled for tonight', timeAgo: '1 day ago' },
      { icon: 'folder_open', description: "New project 'Hatchery C' is now fundraising", timeAgo: '3 days ago' },
    ];
  }
}
