import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ReservationsService } from './reservations.service';
import {
  CreateReservationDto,
  UpdateReservationDto,
} from './dto/reservation.dto';

@Controller('reservations')
@UseGuards(JwtAuthGuard)
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  // Crear una nueva reserva
  @Post()
  create(@Request() req, @Body() createReservationDto: CreateReservationDto) {
    return this.reservationsService.create(req.user.id, createReservationDto);
  }

  // Obtener mis reservas (cliente)
  @Get('my-reservations')
  findMyReservations(@Request() req) {
    return this.reservationsService.findMyReservations(req.user.id);
  }

  // Obtener reservas de mis bares (owner)
  @Get('owner-reservations')
  findOwnerReservations(@Request() req) {
    return this.reservationsService.findReservationsForOwner(req.user.id);
  }

  // Obtener una reserva específica
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.reservationsService.findOne(id);
  }

  // Actualizar una reserva
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateReservationDto: UpdateReservationDto,
  ) {
    return this.reservationsService.update(
      id,
      req.user.id,
      req.user.role,
      updateReservationDto,
    );
  }

  // Cancelar una reserva
  @Patch(':id/cancel')
  cancel(@Param('id') id: string, @Request() req) {
    return this.reservationsService.cancel(id, req.user.id, req.user.role);
  }

  // Confirmar una reserva (solo owner)
  @Patch(':id/confirm')
  confirm(@Param('id') id: string, @Request() req) {
    return this.reservationsService.confirm(id, req.user.id);
  }

  // Completar una reserva (solo owner)
  @Patch(':id/complete')
  complete(@Param('id') id: string, @Request() req) {
    return this.reservationsService.complete(id, req.user.id);
  }

  // Eliminar una reserva
  @Delete(':id')
  remove(@Param('id') id: string, @Request() req) {
    return this.reservationsService.remove(id, req.user.id, req.user.role);
  }
}
