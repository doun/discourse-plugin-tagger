
# Integrate our plugin with Discourse


# add our tags to the topics
module TopicExtender
	def self.included(klass)
		klass.has_and_belongs_to_many :tags, autosave: true, class_name: "::Tagger::Tag"
	end
end


Topic.send(:include, TopicExtender)

module AddTagsToCategories
    # def self.included(klass)
    #     klass.attributes :listable_tags
    # end

    def listable_tags
        Tagger::Tag.where(:listable => true)
    end
end


CategoryList.send(:include, AddTagsToCategories)


# add the tags to the serializer
module ExtendTopicViewSerializer
  def self.included(klass)
    klass.attributes :tags
  end

	def tags
		object.topic.tags.map {|t| t.title} || []
	end
end

TopicViewSerializer.send(:include, ExtendTopicViewSerializer)

# And mount the engine
Discourse::Application.routes.append do
	mount Tagger::Engine, at: '/tagger'
end
