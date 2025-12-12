import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Reservation, ReservationStatus } from './reservation.schema';
import {
  CreateReservationDto,
  UpdateReservationDto,
} from './dto/reservation.dto';

@Injectable()
export class ReservationsService {
  constructor(
    @InjectModel(Reservation.name)
    private reservationModel: Model<Reservation>,
  ) {}

  // Crear una nueva reserva (cliente)
  async create(
    userId: string,
    createReservationDto: CreateReservationDto,
  ): Promise<Reservation> {
    const reservation = new this.reservationModel({
      ...createReservationDto,
      userId: new Types.ObjectId(userId),
      barId: new Types.ObjectId(createReservationDto.barId),
      reservationDate: new Date(createReservationDto.reservationDate),
    });

    return await reservation.save();
  }

  // Obtener todas las reservas del cliente autenticado
  async findMyReservations(userId: string): Promise<Reservation[]> {
    return await this.reservationModel
      .find({ userId: new Types.ObjectId(userId) })
      .populate('barId', 'nameBar location photo')
      .populate('userId', 'fullName email')
      .sort({ reservationDate: -1 })
      .exec();
  }

  // Obtener todas las reservas de los bares del owner
  async findReservationsForOwner(ownerId: string): Promise<Reservation[]> {
    // Primero necesitamos encontrar todos los bares del owner
    const Bar = this.reservationModel.db.model('Bar');
    const ownerBars = await Bar.find({
      ownerId: new Types.ObjectId(ownerId),
    }).select('_id');

    const barIds = ownerBars.map((bar) => bar._id);

    return await this.reservationModel
      .find({ barId: { $in: barIds } })
      .populate('barId', 'nameBar location photo')
      .populate('userId', 'fullName email phone')
      .sort({ reservationDate: -1 })
      .exec();
  }

  // Obtener una reserva por ID
  async findOne(id: string): Promise<Reservation> {
    const reservation = await this.reservationModel
      .findById(id)
      .populate('barId')
      .populate('userId', 'fullName email phone')
      .exec();

    if (!reservation) {
      throw new NotFoundException(`Reservation with ID ${id} not found`);
    }

    return reservation;
  }

  // Actualizar una reserva
  async update(
    id: string,
    userId: string,
    userRole: string,
    updateReservationDto: UpdateReservationDto,
  ): Promise<Reservation> {
    const reservation = await this.findOne(id);

    // Obtener el bar para verificar permisos
    const Bar = this.reservationModel.db.model('Bar');
    const bar = await Bar.findById(reservation.barId);

    // Verificar permisos
    const isOwner = userRole === 'owner' && bar.ownerId.toString() === userId;
    const isClient = reservation.userId.toString() === userId;

    if (!isOwner && !isClient) {
      throw new ForbiddenException(
        'You do not have permission to update this reservation',
      );
    }

    // Solo el owner puede cambiar el status
    if (updateReservationDto.status && !isOwner) {
      throw new ForbiddenException('Only the bar owner can update the status');
    }

    // Convertir fecha si se proporciona
    if (updateReservationDto.reservationDate) {
      updateReservationDto.reservationDate = new Date(
        updateReservationDto.reservationDate,
      ) as any;
    }

    // Actualizar
    Object.assign(reservation, updateReservationDto);
    return await reservation.save();
  }

  // Cancelar una reserva
  async cancel(id: string, userId: string, userRole: string): Promise<void> {
    const reservation = await this.findOne(id);

    // Obtener el bar para verificar permisos
    const Bar = this.reservationModel.db.model('Bar');
    const bar = await Bar.findById(reservation.barId);

    // Verificar permisos
    const isOwner = userRole === 'owner' && bar.ownerId.toString() === userId;
    const isClient = reservation.userId.toString() === userId;

    if (!isOwner && !isClient) {
      throw new ForbiddenException(
        'You do not have permission to cancel this reservation',
      );
    }

    // No se puede cancelar si ya está completada o cancelada
    if (
      reservation.status === ReservationStatus.COMPLETED ||
      reservation.status === ReservationStatus.CANCELLED
    ) {
      throw new BadRequestException(
        `Cannot cancel a reservation that is ${reservation.status}`,
      );
    }

    reservation.status = ReservationStatus.CANCELLED;
    await reservation.save();
  }

  // Confirmar una reserva (solo owner)
  async confirm(id: string, ownerId: string): Promise<Reservation> {
    const reservation = await this.findOne(id);

    // Obtener el bar para verificar permisos
    const Bar = this.reservationModel.db.model('Bar');
    const bar = await Bar.findById(reservation.barId);

    // Verificar que el owner es dueño del bar
    if (bar.ownerId.toString() !== ownerId) {
      throw new ForbiddenException(
        'You do not have permission to confirm this reservation',
      );
    }

    if (reservation.status !== ReservationStatus.PENDING) {
      throw new BadRequestException(
        'Only pending reservations can be confirmed',
      );
    }

    reservation.status = ReservationStatus.CONFIRMED;
    return await reservation.save();
  }

  // Completar una reserva (solo owner)
  async complete(id: string, ownerId: string): Promise<Reservation> {
    const reservation = await this.findOne(id);

    // Obtener el bar para verificar permisos
    const Bar = this.reservationModel.db.model('Bar');
    const bar = await Bar.findById(reservation.barId);

    // Verificar que el owner es dueño del bar
    if (bar.ownerId.toString() !== ownerId) {
      throw new ForbiddenException(
        'You do not have permission to complete this reservation',
      );
    }

    if (reservation.status !== ReservationStatus.CONFIRMED) {
      throw new BadRequestException(
        'Only confirmed reservations can be completed',
      );
    }

    reservation.status = ReservationStatus.COMPLETED;
    return await reservation.save();
  }

  // Eliminar una reserva (solo el cliente que la creó o el owner del bar)
  async remove(id: string, userId: string, userRole: string): Promise<void> {
    const reservation = await this.findOne(id);

    // Obtener el bar para verificar permisos
    const Bar = this.reservationModel.db.model('Bar');
    const bar = await Bar.findById(reservation.barId);

    // Verificar permisos
    const isOwner = userRole === 'owner' && bar.ownerId.toString() === userId;
    const isClient = reservation.userId.toString() === userId;

    if (!isOwner && !isClient) {
      throw new ForbiddenException(
        'You do not have permission to delete this reservation',
      );
    }

    await this.reservationModel.findByIdAndDelete(id);
  }
}
