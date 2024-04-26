const { RaygunWebpackPlugin } = require("@raygun.io/webpack-plugin");

const raygunPlugin = new RaygunWebpackPlugin({
  applicationId: "2bw3ch4",
  patToken: process.env.RAYGUN_PAT_TOKEN, // Your Raygun Personal Access Token
  baseUri: "https://raygun-deployment-tracking-test.vercel.app/",
});

module.exports = {
  publicRuntimeConfig: {
    RAYGUN_API_KEY: process.env.RAYGUN_API_KEY || "",
  },
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.plugins.push(raygunPlugin);
    }
    return config;
  },
};
