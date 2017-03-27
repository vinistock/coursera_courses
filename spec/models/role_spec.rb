describe Role, type: :model do
  context 'user assigned roles' do
    let(:user) { create(:user) }

    it 'has roles' do
      user.roles.create(role_name: Role::ADMIN)
      user.roles.create(role_name: Role::ORIGINATOR, mname: 'Foo')
      user.roles.create(role_name: Role::ORGANIZER, mname: 'Bar', mid: 1)
      user.roles.create(role_name: Role::MEMBER, mname: 'Baz', mid: 1)

      db_user = User.find(user.id)

      expect(db_user.has_role([Role::ADMIN])).to be_truthy
      expect(db_user.has_role([Role::ORIGINATOR], 'Bar')).to be_falsey
      expect(db_user.has_role([Role::ORIGINATOR], 'Foo')).to be_truthy
      expect(db_user.has_role([Role::MEMBER], 'Baz', 1)).to be_truthy
    end
  end

  context 'admin factory' do
    let(:admin) { build(:admin) }
    let(:db_admin) { create(:admin) }

    it 'builds admin' do
      expect(admin.id).to be_nil
      admin_role = admin.roles.select { |r| r.role_name == Role::ADMIN }.first
      expect(admin_role).to have_attributes(role_name: Role::ADMIN, mname: nil)
    end

    it 'creates admin' do
      db_user = User.find(db_admin.id)
      expect(db_user.has_role([Role::ADMIN], User.name)).to be_truthy
    end
  end
end
