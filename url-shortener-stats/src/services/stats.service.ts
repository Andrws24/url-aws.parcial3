import { StatsRepository } from "../repositories/stats.repository";

export class StatsService {
  repository = new StatsRepository();

  async getStats(codigo: string, fecha?: string) {
    const visits = await this.repository.getVisits(codigo);

    const filtered = fecha ? visits.filter((v) => v.fecha === fecha) : visits;

    const grouped = filtered.reduce(
      (acc, item) => {
        acc[item.fecha] = (acc[item.fecha] || 0) + 1;

        return acc;
      },

      {} as Record<string, number>,
    );

    return grouped;
  }
}
