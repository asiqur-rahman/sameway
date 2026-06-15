import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";
import { PrismaClient } from "../src/generated/prisma/client";
import { buildDatabaseUrl } from "../src/lib/database-url";
import { hashPassword } from "../src/lib/auth/password";

const ssl = process.env.DB_SSL === "true";
const pool = new Pool({
  connectionString: buildDatabaseUrl(),
  ssl: ssl ? { rejectUnauthorized: false } : undefined,
});
const adapter = new PrismaPg(pool);
const db = new PrismaClient({ adapter });

async function main() {
  await db.systemConfig.upsert({
    where: { id: "default" },
    create: {},
    update: {},
  });

  const domains = [
    { domain: "grameenphone.com", autoVerify: true },
    { domain: "banglalink.net", autoVerify: true },
    { domain: "robidata.com", autoVerify: false },
    { domain: "sameway.local", autoVerify: true },
    { domain: "gmail.com", autoVerify: false },
  ];

  for (const d of domains) {
    await db.allowedDomain.upsert({
      where: { domain: d.domain },
      create: d,
      update: d,
    });
  }

  const adminPassword = await hashPassword("Admin@12345");
  await db.user.upsert({
    where: { workEmail: "admin@sameway.local" },
    create: {
      fullName: "SameWay Admin",
      workEmail: "admin@sameway.local",
      phone: "+8801700000000",
      passwordHash: adminPassword,
      role: "ADMIN",
      verificationStatus: "VERIFIED",
      companyDomain: "sameway.local",
      workEmailVerified: true,
      officeLocationVerified: true,
      employeeIdVerified: true,
      reminderSettings: { create: {} },
    },
    update: {},
  });

  const demoPassword = await hashPassword("Demo@12345");
  const demo = await db.user.upsert({
    where: { workEmail: "demo@sameway.local" },
    create: {
      fullName: "Demo User",
      workEmail: "demo@sameway.local",
      phone: "+8801711111111",
      passwordHash: demoPassword,
      role: "USER",
      verificationStatus: "VERIFIED",
      companyDomain: "sameway.local",
      commuteType: "BOTH",
      workEmailVerified: true,
      officeLocationVerified: true,
      employeeIdVerified: true,
      reminderSettings: { create: {} },
    },
    update: {},
  });

  await db.vehicle.upsert({
    where: { userId_licensePlate: { userId: demo.id, licensePlate: "DHK-1234" } },
    create: {
      userId: demo.id,
      type: "CAR",
      makeModel: "Toyota Axio",
      licensePlate: "DHK-1234",
      availableSeats: 3,
    },
    update: {},
  });

  console.log("Seed complete:");
  console.log("  Admin: admin@sameway.local / Admin@12345");
  console.log("  Demo:  demo@sameway.local / Demo@12345");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await db.$disconnect();
    await pool.end();
  });
