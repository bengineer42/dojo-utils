use core::serde::Serde;
use dojo::world::WorldStorage;
use dojo::event::EventStorage;
use achievement::types::task::Task;
use achievement::events::creation::TrophyCreation;
use achievement::events::progress::TrophyProgression;

pub trait TaskIdTrait<T>{
    fn to_felt252(self: @T) -> felt252;
}

#[derive(Drop, Serde)]
pub struct TaskInput<T> {
    id: T,
    total: u32,
    description: ByteArray,
}

#[derive(Drop)]
pub struct TrophyCreationInput<T> {
    id: felt252,
    hidden: bool,
    index: u8,
    points: u16,
    start: u64,
    end: u64,
    group: felt252,
    icon: felt252,
    title: felt252,
    description: ByteArray,
    tasks: Array<TaskInput<T>>,
    data: ByteArray,
}

pub impl SerdeImpl<T, +Serde<TaskInput<T>>, +Drop<T>> of Serde<TrophyCreationInput<T>> {
    fn serialize(self: @TrophyCreationInput<T>, ref output: Array<felt252>) {
        
        output.append_span(
            [
                (*self.id),
                (*self.hidden).into(),
                (*self.index).into(),
                (*self.points).into(),
                (*self.start).into(),
                (*self.end).into(),
                (*self.group),
                (*self.icon),
                (*self.title),
            ].span()
        );
        self.description.serialize(ref output);
        output.append(self.tasks.len().into());
        for task in self.tasks.span() {
            task.serialize(ref output);
        };
        self.data.serialize(ref output);
    }

    fn deserialize(ref serialized: Span<felt252>) -> Option<TrophyCreationInput<T>> {
        let (id, hidden, index, points, start, end, group, icon, title) = (
            (*serialized.pop_front()?),
            (*serialized.pop_front()?) != 0,
            (*serialized.pop_front()?).try_into()?,
            (*serialized.pop_front()?).try_into()?,
            (*serialized.pop_front()?).try_into()?,
            (*serialized.pop_front()?).try_into()?,
            (*serialized.pop_front()?),
            (*serialized.pop_front()?),
            (*serialized.pop_front()?),
        );
        let description: ByteArray = Serde::deserialize(ref serialized)?;
        let tasks_len: u32 = (*serialized.pop_front()?).try_into()?;
        let mut tasks: Array<TaskInput<T>> = ArrayTrait::<TaskInput<T>>::new();
        let mut serializable = true;
        for _ in 0..tasks_len {
            match Serde::deserialize(ref serialized){
                Option::None => {
                    serializable = false;
                    break;
                },
                Option::Some(task) => {
                    tasks.append(task);
                }
            }
        };
        if !serializable {
            return Option::None;
        };
        let data: ByteArray = Serde::deserialize(ref serialized)?;
        Option::Some(TrophyCreationInput {
            id,
            hidden,
            index,
            points,
            start,
            end,
            group,
            icon,
            title,
            description,
            tasks,
            data,
        })
    }
}

pub impl TaskInputIntoTask<T, +TaskIdTrait<T>, +Drop<T>> of Into<TaskInput<T>, Task> {
    fn into(self: TaskInput<T>) -> Task {
        Task { id: TaskIdTrait::to_felt252(@self.id), total: self.total, description: self.description }
    }
}



pub impl CreationInputIntoTrophyCreation<T, +TaskIdTrait<T>, +Drop<T>> of Into<TrophyCreationInput<T>, TrophyCreation> {
    fn into(self: TrophyCreationInput<T>) -> TrophyCreation {
        let mut tasks = ArrayTrait::<Task>::new();
        for task in self.tasks {
            tasks.append(task.into());
        };
        TrophyCreation {
            id: self.id,
            hidden: self.hidden,
            index: self.index,
            points: self.points,
            start: self.start,
            end: self.end,
            group: self.group,
            icon: self.icon,
            title: self.title,
            description: self.description,
            tasks: tasks.span(),
            data: self.data,
        }
    }
}

#[generate_trait]
pub impl AchievementsEventsImpl of AchievementsEvents {
    fn emit_achievement_creation(ref self: WorldStorage, trophy: TrophyCreation) {
        self.emit_event(@trophy);
    }
    fn emit_achievement_progress<T, +TaskIdTrait<T>, +Drop<T>>(
        ref self: WorldStorage, player_id: felt252, task: T, count: u32, time: u64,
    ) {
        self
            .emit_event(
                @TrophyProgression { player_id: player_id, task_id: task.to_felt252(), count, time },
            );
    }
}
