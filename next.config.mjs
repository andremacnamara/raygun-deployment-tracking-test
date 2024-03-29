/** @type {import('next').NextConfig} */
const nextConfig = {
  // Define environment variables
  env: {
    RAYGUN_API_KEY: process.env.RAYGUN_API_KEY,
    // Add more environment variables as needed
  },
};

export default nextConfig;
