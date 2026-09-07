import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_organization_details.dart';
import 'organization_event.dart';
import 'organization_state.dart';

class OrganizationBloc
    extends Bloc<OrganizationEvent, OrganizationState> {

  final GetOrganizationDetails
      getOrganizationDetails;

  OrganizationBloc({
    required this.getOrganizationDetails,
  }) : super(OrganizationInitial()) {

    on<GetOrganizationDetailsEvent>(
      _getOrganizationDetails,
    );
  }

  Future<void> _getOrganizationDetails(
    GetOrganizationDetailsEvent event,
    Emitter<OrganizationState> emit,
  ) async {

    emit(OrganizationLoading());

    try {
      final organization =
          await getOrganizationDetails();

      emit(
        OrganizationLoaded(
          organization: organization,
        ),
      );
    } catch (e) {

      emit(
        OrganizationError(
          message: e.toString(),
        ),
      );
    }
  }
}