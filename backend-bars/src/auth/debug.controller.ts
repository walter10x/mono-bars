import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('debug')
export class DebugController {
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getMe(@Request() req) {
    console.log('🔍 DEBUG - USER INFO');
    console.log('req.user completo:', JSON.stringify(req.user, null, 2));
    console.log('req.user.userId:', req.user.userId);
    console.log('Tipo de req.user.userId:', typeof req.user.userId);
    
    return {
      message: 'Información del usuario autenticado',
      user: req.user,
      userIdType: typeof req.user.userId,
      userId: req.user.userId,
    };
  }
}
