// src/auth/auth.controller.ts
import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginUserDto } from './dto/login-user.dto';
import { RequestResetPasswordDto } from './dto/request-reset-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() loginDto: LoginUserDto) {
    const user = await this.authService.validateUser(loginDto.email, loginDto.password);
    return this.authService.login(user);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout(@Request() req) {
    return this.authService.logout(req.user);
  }

  @Post('request-reset')
  async requestPasswordReset(@Body() requestResetDto: RequestResetPasswordDto) {
    return this.authService.requestPasswordReset(requestResetDto.email);
  }

  @Post('reset-password')
  async resetPassword(@Body() resetDto: ResetPasswordDto) {
    return this.authService.resetPassword(resetDto.token, resetDto.newPassword);
  }
}
