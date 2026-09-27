import 'package:appflowy/generated/flowy_svgs.g.dart';
import 'package:appflowy_backend/protobuf/flowy-ai/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_entities.g.dart';

class AIStreamEventPrefix {
  static const data = 'data:';
  static const error = 'error:';
  static const metadata = 'metadata:';
  static const start = 'start:';
  static const finish = 'finish:';
  static const comment = 'comment:';
  static const aiResponseLimit = 'ai_response_limit:';
  static const aiImageResponseLimit = 'ai_image_response_limit:';
  static const aiMaxRequired = 'ai_max_required:';
  static const localAINotReady = 'local_ai_not_ready:';
  static const localAIDisabled = 'local_ai_disabled:';
  static const aiFollowUp = 'ai_follow_up:';
}

enum AiType {
  cloud,
  local;

  bool get isCloud => this == cloud;
  bool get isLocal => this == local;
}

class PredefinedFormat extends Equatable {
  const PredefinedFormat({
    required this.imageFormat,
    required this.textFormat,
  });

  final ImageFormat imageFormat;
  final TextFormat? textFormat;

  PredefinedFormatPB toPB() {
    return PredefinedFormatPB(
      imageFormat: switch (imageFormat) {
        ImageFormat.text => ResponseImageFormatPB.TextOnly,
        ImageFormat.image => ResponseImageFormatPB.ImageOnly,
        ImageFormat.textAndImage => ResponseImageFormatPB.TextAndImage,
      },
      textFormat: switch (textFormat) {
        TextFormat.paragraph => ResponseTextFormatPB.Paragraph,
        TextFormat.bulletList => ResponseTextFormatPB.BulletedList,
        TextFormat.numberedList => ResponseTextFormatPB.NumberedList,
        TextFormat.table => ResponseTextFormatPB.Table,
        _ => null,
      },
    );
  }

  @override
  List<Object?> get props => [imageFormat, textFormat];
}

enum ImageFormat {
  text,
  image,
  textAndImage;

  bool get hasText => this == text || this == textAndImage;

  FlowySvgData get icon {
    return switch (this) {
      ImageFormat.text => FlowySvgs.ai_text_s,
      ImageFormat.image => FlowySvgs.ai_image_s,
      ImageFormat.textAndImage => FlowySvgs.ai_text_image_s,
    };
  }

  String get i18n {
    return switch (this) {
      ImageFormat.text => '文本',
      ImageFormat.image => '仅图片',
      ImageFormat.textAndImage =>
        '文本与图片',
    };
  }
}

enum TextFormat {
  paragraph,
  bulletList,
  numberedList,
  table;

  FlowySvgData get icon {
    return switch (this) {
      TextFormat.paragraph => FlowySvgs.ai_paragraph_s,
      TextFormat.bulletList => FlowySvgs.ai_list_s,
      TextFormat.numberedList => FlowySvgs.ai_number_list_s,
      TextFormat.table => FlowySvgs.ai_table_s,
    };
  }

  String get i18n {
    return switch (this) {
      TextFormat.paragraph => '段落',
      TextFormat.bulletList => '项目符号清单',
      TextFormat.numberedList => '编号清单',
      TextFormat.table => '表格',
    };
  }
}

enum AiPromptCategory {
  other,
  development,
  writing,
  healthAndFitness,
  business,
  marketing,
  travel,
  contentSeo,
  emailMarketing,
  paidAds,
  prCommunication,
  recruiting,
  sales,
  socialMedia,
  strategy,
  caseStudies,
  salesCopy,
  education,
  work,
  podcastProduction,
  copyWriting,
  customerSuccess;

  String get i18n => _zhName;

  String get _zhName {
    return switch (this) {
      other => '其他',
      development => '开发',
      writing => '写作',
      healthAndFitness => '健康与健身',
      business => '商业',
      marketing => '市场营销',
      travel => '旅行',
      contentSeo => '内容/SEO',
      emailMarketing => '邮件营销',
      paidAds => '付费广告',
      prCommunication => '公关传播',
      recruiting => '招聘',
      sales => '销售',
      socialMedia => '社交媒体',
      strategy => '战略',
      caseStudies => '案例研究',
      salesCopy => '销售文案',
      education => '教育',
      work => '工作',
      podcastProduction => '播客制作',
      copyWriting => '文案写作',
      customerSuccess => '客户成功',
    };
  }
}

@JsonSerializable()
class AiPrompt extends Equatable {
  const AiPrompt({
    required this.id,
    required this.name,
    required this.content,
    required this.category,
    required this.example,
    required this.isFeatured,
    required this.isCustom,
  });

  factory AiPrompt.fromPB(CustomPromptPB pb) {
    final map = _buildCategoryNameMap();
    final categories = pb.category
        .split(',')
        .map((categoryName) => categoryName.trim())
        .map(
          (categoryName) {
            final entry = map.entries.firstWhereOrNull(
              (entry) =>
                  entry.value.$1 == categoryName ||
                  entry.value.$2 == categoryName,
            );
            return entry?.key ?? AiPromptCategory.other;
          },
        )
        .toSet()
        .toList();

    return AiPrompt(
      id: pb.id,
      name: pb.name,
      content: pb.content,
      category: categories,
      example: pb.example,
      isFeatured: false,
      isCustom: true,
    );
  }

  factory AiPrompt.fromJson(Map<String, dynamic> json) =>
      _$AiPromptFromJson(json);

  Map<String, dynamic> toJson() => _$AiPromptToJson(this);

  final String id;
  final String name;
  final String content;
  @JsonKey(fromJson: _categoryFromJson)
  final List<AiPromptCategory> category;
  @JsonKey(defaultValue: "")
  final String example;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(defaultValue: false)
  final bool isCustom;

  @override
  List<Object?> get props =>
      [id, name, content, category, example, isFeatured, isCustom];

  static Map<AiPromptCategory, (String, String)> _buildCategoryNameMap() {
    return {
      for (final category in AiPromptCategory.values)
        category: (category._zhName, category._zhName),
    };
  }

  static List<AiPromptCategory> _categoryFromJson(dynamic json) {
    if (json is String) {
      return json
          .split(',')
          .map((categoryName) => categoryName.trim())
          .map(
            (categoryName) => $enumDecode(
              _aiPromptCategoryEnumMap,
              categoryName,
              unknownValue: AiPromptCategory.other,
            ),
          )
          .toSet()
          .toList();
    }

    return [AiPromptCategory.other];
  }
}

const _aiPromptCategoryEnumMap = {
  AiPromptCategory.other: 'other',
  AiPromptCategory.development: 'development',
  AiPromptCategory.writing: 'writing',
  AiPromptCategory.healthAndFitness: 'healthAndFitness',
  AiPromptCategory.business: 'business',
  AiPromptCategory.marketing: 'marketing',
  AiPromptCategory.travel: 'travel',
  AiPromptCategory.contentSeo: 'contentSeo',
  AiPromptCategory.emailMarketing: 'emailMarketing',
  AiPromptCategory.paidAds: 'paidAds',
  AiPromptCategory.prCommunication: 'prCommunication',
  AiPromptCategory.recruiting: 'recruiting',
  AiPromptCategory.sales: 'sales',
  AiPromptCategory.socialMedia: 'socialMedia',
  AiPromptCategory.strategy: 'strategy',
  AiPromptCategory.caseStudies: 'caseStudies',
  AiPromptCategory.salesCopy: 'salesCopy',
  AiPromptCategory.education: 'education',
  AiPromptCategory.work: 'work',
  AiPromptCategory.podcastProduction: 'podcastProduction',
  AiPromptCategory.copyWriting: 'copyWriting',
  AiPromptCategory.customerSuccess: 'customerSuccess',
};

class CustomPromptDatabaseConfig extends Equatable {
  const CustomPromptDatabaseConfig({
    required this.view,
    required this.titleFieldId,
    required this.contentFieldId,
    required this.exampleFieldId,
    required this.categoryFieldId,
  });

  factory CustomPromptDatabaseConfig.fromAiPB(
    CustomPromptDatabaseConfigurationPB pb,
    ViewPB view,
  ) {
    final config = CustomPromptDatabaseConfig(
      view: view,
      titleFieldId: pb.titleFieldId,
      contentFieldId: pb.contentFieldId,
      exampleFieldId: pb.hasExampleFieldId() ? pb.exampleFieldId : null,
      categoryFieldId: pb.hasCategoryFieldId() ? pb.categoryFieldId : null,
    );

    return config;
  }

  factory CustomPromptDatabaseConfig.fromDbPB(
    CustomPromptDatabaseConfigPB pb,
    ViewPB view,
  ) {
    final config = CustomPromptDatabaseConfig(
      view: view,
      titleFieldId: pb.titleFieldId,
      contentFieldId: pb.contentFieldId,
      exampleFieldId: pb.hasExampleFieldId() ? pb.exampleFieldId : null,
      categoryFieldId: pb.hasCategoryFieldId() ? pb.categoryFieldId : null,
    );

    return config;
  }

  final ViewPB view;
  final String titleFieldId;
  final String contentFieldId;
  final String? exampleFieldId;
  final String? categoryFieldId;

  @override
  List<Object?> get props =>
      [view.id, titleFieldId, contentFieldId, exampleFieldId, categoryFieldId];

  CustomPromptDatabaseConfig copyWith({
    ViewPB? view,
    String? titleFieldId,
    String? contentFieldId,
    String? exampleFieldId,
    String? categoryFieldId,
  }) {
    return CustomPromptDatabaseConfig(
      view: view ?? this.view,
      titleFieldId: titleFieldId ?? this.titleFieldId,
      contentFieldId: contentFieldId ?? this.contentFieldId,
      exampleFieldId: exampleFieldId ?? this.exampleFieldId,
      categoryFieldId: categoryFieldId ?? this.categoryFieldId,
    );
  }

  CustomPromptDatabaseConfigurationPB toAiPB() {
    final payload = CustomPromptDatabaseConfigurationPB.create()
      ..viewId = view.id
      ..titleFieldId = titleFieldId
      ..contentFieldId = contentFieldId;

    if (exampleFieldId != null) {
      payload.exampleFieldId = exampleFieldId!;
    }
    if (categoryFieldId != null) {
      payload.categoryFieldId = categoryFieldId!;
    }

    return payload;
  }

  CustomPromptDatabaseConfigPB toDbPB() {
    final payload = CustomPromptDatabaseConfigPB.create()
      ..viewId = view.id
      ..titleFieldId = titleFieldId
      ..contentFieldId = contentFieldId;

    if (exampleFieldId != null) {
      payload.exampleFieldId = exampleFieldId!;
    }
    if (categoryFieldId != null) {
      payload.categoryFieldId = categoryFieldId!;
    }

    return payload;
  }
}
