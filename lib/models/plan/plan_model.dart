/// Plan Model
/// Represents a subscription plan with pricing and features
class PlanModel {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final String priceId;


  PlanModel({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.priceId,
  });
}



