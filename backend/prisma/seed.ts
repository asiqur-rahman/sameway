import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";
import { PrismaClient } from "../src/generated/prisma/client";
import { buildDatabaseUrl } from "../src/lib/database-url";
import { hashPassword } from "../src/lib/auth/password";
import { buildSegments } from "../src/modules/matching/matching.service";

const ssl = process.env.DB_SSL === "true";
const pool = new Pool({
  connectionString: buildDatabaseUrl(),
  ssl: ssl ? { rejectUnauthorized: false } : undefined,
});
const adapter = new PrismaPg(pool);
const db = new PrismaClient({ adapter });

/** Dhaka commute corridor for demo search. */
const DEMO_HOME = {
  address: "Uttara Sector 4, Dhaka",
  lat: 23.8759,
  lng: 90.3795,
};
const DEMO_OFFICE = {
  address: "Motijheel, Dhaka",
  lat: 23.733,
  lng: 90.4172,
};

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
      companyName: "Same Way",
      workEmailVerified: true,
      officeLocationVerified: true,
      employeeIdVerified: true,
      reminderSettings: { create: {} },
    },
    update: {},
  });

  const driverPassword = await hashPassword("Driver@12345");
  const driver = await db.user.upsert({
    where: { workEmail: "driver@sameway.local" },
    create: {
      fullName: "Karim Rahman",
      workEmail: "driver@sameway.local",
      phone: "+8801722222222",
      passwordHash: driverPassword,
      role: "USER",
      verificationStatus: "VERIFIED",
      companyDomain: "grameenphone.com",
      companyName: "Grameenphone",
      commuteType: "DRIVE",
      workEmailVerified: true,
      officeLocationVerified: true,
      employeeIdVerified: true,
      rating: 4.8,
      rideCount: 47,
      reminderSettings: { create: {} },
    },
    update: {},
  });

  await db.place.upsert({
    where: { userId_label: { userId: demo.id, label: "HOME" } },
    create: { userId: demo.id, label: "HOME", ...DEMO_HOME },
    update: DEMO_HOME,
  });
  await db.place.upsert({
    where: { userId_label: { userId: demo.id, label: "OFFICE" } },
    create: { userId: demo.id, label: "OFFICE", ...DEMO_OFFICE },
    update: DEMO_OFFICE,
  });

  const demoVehicle = await db.vehicle.upsert({
    where: { userId_licensePlate: { userId: demo.id, licensePlate: "DHK-1234" } },
    create: {
      userId: demo.id,
      type: "CAR",
      makeModel: "Toyota Axio",
      licensePlate: "DHK-1234",
      availableSeats: 3,
      color: "White",
      usuallyLeave: "8:30 AM",
    },
    update: {},
  });

  const driverVehicle = await db.vehicle.upsert({
    where: { userId_licensePlate: { userId: driver.id, licensePlate: "DHK-5678" } },
    create: {
      userId: driver.id,
      type: "CAR",
      makeModel: "Toyota Allion",
      licensePlate: "DHK-5678",
      availableSeats: 2,
      color: "Silver",
      usuallyLeave: "8:25 AM",
    },
    update: {},
  });

  const departureAt = new Date();
  departureAt.setHours(departureAt.getHours() + 2, 0, 0, 0);

  const driverStart = { address: "Uttara Sector 7, Dhaka", lat: 23.8695, lng: 90.385 };
  const driverEnd = DEMO_OFFICE;
  const segments = buildSegments(driverStart, driverEnd, []);

  await db.ride.deleteMany({ where: { driverId: driver.id } });
  await db.ride.create({
    data: {
      driverId: driver.id,
      vehicleId: driverVehicle.id,
      startAddress: driverStart.address,
      startLat: driverStart.lat,
      startLng: driverStart.lng,
      endAddress: driverEnd.address,
      endLat: driverEnd.lat,
      endLng: driverEnd.lng,
      stops: [],
      segments: segments as object,
      departureAt,
      repeat: "WEEKDAYS",
      availableSeats: 2,
      status: "OPEN",
      participants: {
        create: { userId: driver.id, role: "DRIVER", status: "CONFIRMED" },
      },
    },
  });

  console.log("Seed complete:");
  console.log("  Admin:  admin@sameway.local / Admin@12345");
  console.log("  Demo:   demo@sameway.local / Demo@12345 (rider, HOME/OFFICE pinned)");
  console.log("  Driver: driver@sameway.local / Driver@12345 (OPEN ride Uttara → Motijheel)");
  void demoVehicle;
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
