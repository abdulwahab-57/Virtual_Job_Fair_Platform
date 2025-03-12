# Zoom Integration for Virtual Job Fair Platform

This document provides instructions on how to set up and use the Zoom integration for the Virtual Job Fair Platform.

## Setup Instructions

### 1. Create a Zoom OAuth App

1. Go to the [Zoom App Marketplace](https://marketplace.zoom.us/) and sign in with your Zoom account.
2. Click on "Develop" in the top-right corner and select "Build App".
3. Choose "OAuth" as the app type.
4. Fill in the required information for your app:
   - App Name: Virtual Job Fair Platform
   - App Type: Account-level app
   - Deauthorization Notification URL: Your app's URL + `/zoom/deauthorize` (e.g., `https://your-app.com/zoom/deauthorize`)
5. Add the following scopes:
   - `meeting:write:admin`
   - `meeting:read:admin`
   - `user:read:admin`
6. Set the Redirect URL to your app's URL + `/zoom/callback` (e.g., `https://your-app.com/zoom/callback`).
7. Save your app and note down the Client ID and Client Secret.

### 2. Configure Environment Variables

1. Copy the `.env.example` file to `.env`:
   ```
   cp .env.example .env
   ```
2. Update the `.env` file with your Zoom credentials:
   ```
   ZOOM_CLIENT_ID=your_zoom_client_id
   ZOOM_CLIENT_SECRET=your_zoom_client_secret
   ENCRYPTION_KEY=your_encryption_key_32_bytes_long
   ```
   
   To generate a secure encryption key, you can use:
   ```
   rails secret | head -c 32
   ```

### 3. Run Migrations

Run the database migrations to create the necessary tables:

```
rails db:migrate
```

## Usage Instructions

### For Career Officers

1. **Connect to Zoom**:
   - Go to the Meetings page.
   - Click on "Connect to Zoom" to authorize the application to use your Zoom account.
   - Follow the prompts to complete the authorization.

2. **Create a Meeting**:
   - Go to the Meetings page.
   - Click on "New Meeting".
   - Fill in the meeting details (title, description, start time, end time).
   - Select the students and recruiters to invite.
   - Click "Create Meeting".

3. **Manage Meetings**:
   - View all meetings on the Meetings page.
   - Click on a meeting to view its details.
   - Add or remove participants.
   - Start, end, or cancel meetings.

4. **Job Fair Arena**:
   - Go to the Job Fair Arena page to see all active virtual booths.
   - Click on a booth to join as a co-host.
   - You can leave the meeting at any time without ending it.

### For Students and Recruiters

1. **View Scheduled Meetings**:
   - Go to the Virtual Booth page to see all your scheduled meetings.
   - Upcoming meetings will show the start time.
   - Active meetings will show a "Join Meeting" button.

2. **Join a Meeting**:
   - When a meeting is active, click on "Join Meeting" to enter the virtual booth.
   - The meeting will be displayed in an embedded Zoom interface.
   - You can see the time remaining for the meeting.

## Troubleshooting

- **Zoom Connection Issues**:
  - If you encounter issues connecting to Zoom, try reconnecting by clicking "Connect to Zoom" again.
  - Check that your Zoom account has the necessary permissions.

- **Meeting Creation Issues**:
  - Ensure that your Zoom credentials are valid.
  - Check that the meeting times are valid (end time must be after start time).

- **Joining Meeting Issues**:
  - Make sure you are a participant in the meeting.
  - Check that the meeting is currently active.
  - Ensure your browser allows camera and microphone access.

## Security Considerations

- All sensitive data (access tokens, refresh tokens, meeting passwords) are encrypted in the database.
- Only career officers can create and manage meetings.
- Only participants added to a meeting can join it.
- Zoom OAuth tokens are automatically refreshed when they expire.

## Support

If you encounter any issues or have questions, please contact the system administrator. 