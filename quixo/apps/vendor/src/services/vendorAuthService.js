// Re-exported from vendorApi.js for backward compatibility
import { vendorAuthAPI } from './vendorApi';

export const vendorLogin = (phone) => vendorAuthAPI.login(phone);
export const vendorLoginOtp = (phone, otp) => vendorAuthAPI.verifyLoginOtp(phone, otp);
export const vendorRegister = (data) => vendorAuthAPI.register(data);
export const vendorRegisterOtp = (phone, otp) => vendorAuthAPI.verifyRegistrationOtp(phone, otp);
export const vendorProfile = () => vendorAuthAPI.getProfile();
export const vendorProfileUpdate = (data) => vendorAuthAPI.updateProfile(data);
