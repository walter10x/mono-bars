import { Injectable, CanActivate, ExecutionContext, SetMetadata } from '@nestjs/common';
import { Reflector } from '@nestjs/core';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) {
      return true; // Si no hay roles definidos, se permite acceso
    }

    const { user } = context.switchToHttp().getRequest();

    // Depuración: imprimir rol del usuario recibido
    console.log('RolesGuard - Usuario autenticado:', user);

    // Compara si el rol del usuario está incluido en los roles permitidos (case insensitive)
    return requiredRoles.some(role => role.toLowerCase() === user.role?.toLowerCase());
  }
}
