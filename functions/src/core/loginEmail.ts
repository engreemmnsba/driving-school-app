/** Firebase Auth needs an email; people log in with their national ID. Same as the app (login_email.dart). */
export const loginEmail = (nationalId: string): string => `${nationalId.trim()}@login.your-firebase-project.web.app`;
