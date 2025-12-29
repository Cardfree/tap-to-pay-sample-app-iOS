# Sample App Setup

This sample app requires an API key.

## Steps

1. Copy the template config file:

```bash
cp LocalConfig.xcconfig.example LocalConfig.xcconfig

2. Open LocalConfig.xcconfig and replace all 'REPLACE_ME' with your actual values:
DEV_API_KEY=your_real_dev_api_key_here
UAT_API_KEY=your_real_uat_api_key_here
PROD_API_KEY=your_real_prod_api_key_here
DEEPLINK_SCHEME=deeplink_scheme_you_would_like_to_use
DEEPLINK_HOST=deeplink_host_you_would_like_to_use

3. Make sure your Xcode target uses LocalConfig.xcconfig as the Base Configuration.
In Xcode, you can set this by tapping on your project root at the top of Project navigator on the left.
Then tap on your project under the 'Project' section.
Then tap on 'Info'.
For each configuration, set the configuration file to 'LocalConfig.xcconfig'

4. Build and run the project.

Note: LocalConfig.xcconfig is ignored by Git. Do not commit your real API key.
