import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.proposal.deleteMany();
  await prisma.job.deleteMany();
  await prisma.user.deleteMany();

  await prisma.user.create({
    data: {
      email: 'demo.client@prolance.app',
      name: 'Marcus Thompson',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      role: 'CLIENT',
      skills: [],
      location: 'Remote',
    },
  });

  const now = new Date();
  await prisma.job.createMany({
    data: [
      {
        title: 'Flutter App for E-commerce Startup',
        description:
          'We need a skilled Flutter developer to build a cross-platform e-commerce app with product catalog, cart, checkout, and user authentication.',
        clientName: 'Marcus Thompson',
        clientAvatar: 'https://i.pravatar.cc/150?img=12',
        budgetMin: 2500,
        budgetMax: 5000,
        budgetType: 'fixed',
        category: 'Mobile Development',
        skills: ['Flutter', 'Dart', 'REST APIs', 'Firebase'],
        experienceLevel: 'Intermediate',
        duration: '1-3 months',
        proposalCount: 12,
        isSaved: false,
        status: 'open',
        isUserPosted: false,
        postedDate: new Date(now.getTime() - 3 * 3600_000),
      },
      {
        title: 'React SPA with Design System',
        description:
          'Modern responsive React dashboard with Storybook, accessibility, and REST integration.',
        clientName: 'Elena Rodriguez',
        clientAvatar: 'https://i.pravatar.cc/150?img=5',
        budgetMin: 40,
        budgetMax: 75,
        budgetType: 'hourly',
        category: 'Web Development',
        skills: ['React', 'TypeScript', 'REST APIs', 'Figma handoff'],
        experienceLevel: 'Expert',
        duration: 'Less than 1 month',
        proposalCount: 8,
        isSaved: false,
        status: 'open',
        isUserPosted: false,
        postedDate: new Date(now.getTime() - 86400_000),
      },
      {
        title: 'SEO Content Sprint',
        description:
          'Four-week SEO landing pages and blog pipeline with analytics tagging.',
        clientName: 'Priya Sharma',
        clientAvatar: 'https://i.pravatar.cc/150?img=20',
        budgetMin: 1200,
        budgetMax: 2200,
        budgetType: 'fixed',
        category: 'Digital Marketing',
        skills: ['SEO', 'Copywriting', 'Analytics GA4'],
        experienceLevel: 'Intermediate',
        duration: '1-3 months',
        proposalCount: 5,
        isSaved: false,
        status: 'open',
        isUserPosted: false,
        postedDate: new Date(now.getTime() - 5 * 86400_000),
      },
    ],
  });
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
